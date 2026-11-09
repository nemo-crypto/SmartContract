use escrow_workflow_demo::Market;
fn main() {
    let mut market = Market::with_balances(&[(1, 1000), (2, 0), (3, 0)]).unwrap();
    let delivered = market.create(1, 2, 3, 100, 0, 60).unwrap();
    market.fund(delivered, 1, 1).unwrap(); market.deliver(delivered, 2, 2).unwrap(); market.confirm(delivered, 1).unwrap();
    let timeout = market.create(1, 2, 3, 200, 0, 60).unwrap();
    market.fund(timeout, 1, 1).unwrap(); market.cancel(timeout, 1, 60).unwrap();
    let disputed = market.create(1, 2, 3, 300, 0, 60).unwrap();
    market.fund(disputed, 1, 1).unwrap(); market.deliver(disputed, 2, 2).unwrap(); market.dispute(disputed, 1).unwrap(); market.resolve(disputed, 3, false).unwrap();
    for event in &market.events { println!("{event}"); }
    println!("buyer={} seller={} total={}", market.balance(1).unwrap(), market.balance(2).unwrap(), market.total_units());
}
