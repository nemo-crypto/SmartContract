//! 纯标准库订单账本：模拟额度与显式时间，不连接区块链或处理真钱。
use std::collections::BTreeMap;
pub type Account = u64;
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum State { Created, Funded, Delivered, Completed, Cancelled, Disputed }
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Order { pub buyer: Account, pub seller: Account, pub arbiter: Account, pub price: u64, pub deadline: u64, pub state: State }
#[derive(Debug, PartialEq, Eq)]
pub enum Error { InvalidTerms, UnknownAccount, UnknownOrder, Unauthorized, InvalidState, InsufficientFunds, Overflow }
#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct Market { balances: BTreeMap<Account, u64>, orders: Vec<Order>, pub events: Vec<String> }
impl Market {
    pub fn with_balances(accounts: &[(Account, u64)]) -> Result<Self, Error> {
        let mut market = Self::default();
        let mut total = 0u64;
        for &(id, amount) in accounts {
            if id == 0 || market.balances.contains_key(&id) { return Err(Error::InvalidTerms); }
            total = total.checked_add(amount).ok_or(Error::Overflow)?;
            market.balances.insert(id, amount);
        }
        Ok(market)
    }
    pub fn balance(&self, id: Account) -> Result<u64, Error> { self.balances.get(&id).copied().ok_or(Error::UnknownAccount) }
    pub fn order(&self, id: usize) -> Result<&Order, Error> { self.orders.get(id).ok_or(Error::UnknownOrder) }
    pub fn create(&mut self, buyer: Account, seller: Account, arbiter: Account, price: u64, now: u64, duration: u64) -> Result<usize, Error> {
        if buyer == seller || buyer == arbiter || seller == arbiter || price == 0 || duration == 0 || duration > 2_592_000 { return Err(Error::InvalidTerms); }
        for a in [buyer, seller, arbiter] { self.balance(a)?; }
        let deadline = now.checked_add(duration).ok_or(Error::Overflow)?;
        let id = self.orders.len();
        self.orders.push(Order { buyer, seller, arbiter, price, deadline, state: State::Created });
        self.events.push(format!("order={id} actor={buyer} state=Created"));
        Ok(id)
    }
    fn transition(&mut self, id: usize, actor: Account, state: State) {
        self.orders[id].state = state;
        self.events.push(format!("order={id} actor={actor} state={state:?}"));
    }
    pub fn fund(&mut self, id: usize, actor: Account, now: u64) -> Result<(), Error> {
        let o = self.order(id)?.clone();
        if actor != o.buyer { return Err(Error::Unauthorized); }
        if o.state != State::Created || now >= o.deadline { return Err(Error::InvalidState); }
        let next = self.balance(actor)?.checked_sub(o.price).ok_or(Error::InsufficientFunds)?;
        self.balances.insert(actor, next); self.transition(id, actor, State::Funded); Ok(())
    }
    pub fn deliver(&mut self, id: usize, actor: Account, now: u64) -> Result<(), Error> {
        let o = self.order(id)?;
        if actor != o.seller { return Err(Error::Unauthorized); }
        if o.state != State::Funded || now >= o.deadline { return Err(Error::InvalidState); }
        self.transition(id, actor, State::Delivered); Ok(())
    }
    fn settle(&mut self, id: usize, actor: Account, recipient: Account, state: State) -> Result<(), Error> {
        let next = self.balance(recipient)?.checked_add(self.order(id)?.price).ok_or(Error::Overflow)?;
        self.balances.insert(recipient, next); self.transition(id, actor, state); Ok(())
    }
    pub fn confirm(&mut self, id: usize, actor: Account) -> Result<(), Error> {
        let o = self.order(id)?.clone();
        if actor != o.buyer { return Err(Error::Unauthorized); }
        if o.state != State::Delivered { return Err(Error::InvalidState); }
        self.settle(id, actor, o.seller, State::Completed)
    }
    pub fn cancel(&mut self, id: usize, actor: Account, now: u64) -> Result<(), Error> {
        let o = self.order(id)?.clone();
        if actor != o.buyer { return Err(Error::Unauthorized); }
        match o.state {
            State::Created => { self.transition(id, actor, State::Cancelled); Ok(()) },
            State::Funded if now >= o.deadline => self.settle(id, actor, o.buyer, State::Cancelled),
            _ => Err(Error::InvalidState)
        }
    }
    pub fn dispute(&mut self, id: usize, actor: Account) -> Result<(), Error> {
        let o = self.order(id)?;
        if actor != o.buyer && actor != o.seller { return Err(Error::Unauthorized); }
        if o.state != State::Delivered { return Err(Error::InvalidState); }
        self.transition(id, actor, State::Disputed); Ok(())
    }
    pub fn resolve(&mut self, id: usize, actor: Account, release: bool) -> Result<(), Error> {
        let o = self.order(id)?.clone();
        if actor != o.arbiter { return Err(Error::Unauthorized); }
        if o.state != State::Disputed { return Err(Error::InvalidState); }
        self.settle(id, actor, if release { o.seller } else { o.buyer }, if release { State::Completed } else { State::Cancelled })
    }
    pub fn total_units(&self) -> u128 {
        let available: u128 = self.balances.values().map(|v| *v as u128).sum();
        available + self.orders.iter().filter(|o| matches!(o.state, State::Funded | State::Delivered | State::Disputed)).map(|o| o.price as u128).sum::<u128>()
    }
}
#[cfg(test)]
mod tests {
    use super::*;
    fn market() -> Market { Market::with_balances(&[(1, 1000), (2, 0), (3, 0), (4, 0)]).unwrap() }
    #[test]
    fn complete_order_and_conserve_units() {
        let mut m = market(); let id = m.create(1, 2, 3, 100, 0, 60).unwrap();
        m.fund(id, 1, 1).unwrap(); assert_eq!(m.balance(1), Ok(900)); assert_eq!(m.total_units(), 1000);
        m.deliver(id, 2, 2).unwrap(); m.confirm(id, 1).unwrap();
        assert_eq!(m.balance(2), Ok(100)); assert_eq!(m.total_units(), 1000);
        assert_eq!(m.confirm(id, 1), Err(Error::InvalidState)); assert_eq!(m.events.len(), 4);
    }
    #[test]
    fn rejected_actions_leave_everything_unchanged() {
        let mut m = market(); let id = m.create(1, 2, 3, 100, 0, 60).unwrap(); let before = m.clone();
        assert_eq!(m.fund(id, 4, 1), Err(Error::Unauthorized));
        assert_eq!(m.confirm(id, 1), Err(Error::InvalidState)); assert_eq!(m, before);
        let expensive = m.create(1, 2, 3, 2000, 0, 60).unwrap(); let before = m.clone();
        assert_eq!(m.fund(expensive, 1, 1), Err(Error::InsufficientFunds)); assert_eq!(m, before);
    }
    #[test]
    fn timeout_and_unfunded_cancellation() {
        let mut m = market(); let id = m.create(1, 2, 3, 100, 0, 60).unwrap(); m.fund(id, 1, 1).unwrap();
        assert_eq!(m.cancel(id, 1, 59), Err(Error::InvalidState));
        assert_eq!(m.deliver(id, 2, 60), Err(Error::InvalidState)); m.cancel(id, 1, 60).unwrap();
        assert_eq!(m.balance(1), Ok(1000)); assert_eq!(m.total_units(), 1000);
        let id = m.create(1, 2, 3, 100, 0, 60).unwrap(); m.cancel(id, 1, 0).unwrap();
        assert_eq!(m.fund(id, 1, 1), Err(Error::InvalidState));
    }
    #[test]
    fn both_arbitration_outcomes() {
        for release in [true, false] {
            let mut m = market(); let id = m.create(1, 2, 3, 100, 0, 60).unwrap(); m.fund(id, 1, 1).unwrap(); m.deliver(id, 2, 2).unwrap();
            assert_eq!(m.dispute(id, 4), Err(Error::Unauthorized)); m.dispute(id, 1).unwrap();
            assert_eq!(m.resolve(id, 1, release), Err(Error::Unauthorized)); m.resolve(id, 3, release).unwrap();
            assert_eq!(m.total_units(), 1000); assert_eq!(m.balance(2), Ok(if release {100} else {0}));
            assert_eq!(m.resolve(id, 3, release), Err(Error::InvalidState));
        }
    }
    #[test]
    fn invalid_terms_and_overflow() {
        let mut m = market();
        assert_eq!(m.create(1, 1, 3, 100, 0, 60), Err(Error::InvalidTerms));
        assert_eq!(m.create(1, 2, 9, 100, 0, 60), Err(Error::UnknownAccount));
        assert_eq!(m.create(1, 2, 3, 100, u64::MAX, 60), Err(Error::Overflow));
        assert_eq!(Market::with_balances(&[(1, u64::MAX), (2, 1)]), Err(Error::Overflow));
    }
}
