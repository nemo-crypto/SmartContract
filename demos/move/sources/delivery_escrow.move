module demo::delivery_escrow {
    use std::signer;
    use std::vector;
    const E_AUTH: u64 = 1;
    const E_STATE: u64 = 2;
    const E_TERMS: u64 = 3;
    const E_BALANCE: u64 = 4;
    const E_UNKNOWN: u64 = 5;
    const E_EXISTS: u64 = 6;

    struct Balance has store, drop { owner: address, units: u64 }
    struct Order has store, drop {
        buyer: address, seller: address, arbiter: address,
        price: u64, deadline: u64, state: u8
    }
    struct Change has store, drop { order_id: u64, actor: address, state: u8 }
    // 模拟额度，不是 Aptos Coin/FungibleAsset。时钟仅用于可重复教学测试。
    struct Market has key {
        balances: vector<Balance>, orders: vector<Order>, journal: vector<Change>, clock: u64
    }
    public entry fun initialize(admin: &signer) {
        assert!(signer::address_of(admin) == @demo, E_AUTH);
        assert!(!exists<Market>(@demo), E_EXISTS);
        move_to(admin, Market { balances: vector[], orders: vector[], journal: vector[], clock: 0 });
    }
    public entry fun register(admin: &signer, owner: address, units: u64) acquires Market {
        assert!(signer::address_of(admin) == @demo, E_AUTH);
        assert!(owner != @0x0, E_TERMS);
        let market = borrow_global_mut<Market>(@demo);
        let i = 0;
        while (i < vector::length(&market.balances)) {
            assert!(vector::borrow(&market.balances, i).owner != owner, E_EXISTS);
            i = i + 1;
        };
        vector::push_back(&mut market.balances, Balance { owner, units });
    }
    public entry fun advance_clock(admin: &signer, now: u64) acquires Market {
        assert!(signer::address_of(admin) == @demo, E_AUTH);
        let market = borrow_global_mut<Market>(@demo);
        assert!(now >= market.clock, E_TERMS);
        market.clock = now;
    }
    fun account_index(accounts: &vector<Balance>, owner: address): u64 {
        let i = 0;
        while (i < vector::length(accounts)) {
            if (vector::borrow(accounts, i).owner == owner) return i;
            i = i + 1;
        };
        abort E_UNKNOWN
    }
    fun change(market: &mut Market, id: u64, actor: address, state: u8) {
        vector::borrow_mut(&mut market.orders, id).state = state;
        vector::push_back(&mut market.journal, Change { order_id: id, actor, state });
    }
    public fun create(buyer: &signer, seller: address, arbiter: address, price: u64, duration: u64): u64 acquires Market {
        let buyer = signer::address_of(buyer);
        assert!(buyer != seller && buyer != arbiter && seller != arbiter, E_TERMS);
        assert!(price > 0 && duration > 0 && duration <= 2592000, E_TERMS);
        let market = borrow_global_mut<Market>(@demo);
        account_index(&market.balances, buyer);
        account_index(&market.balances, seller);
        account_index(&market.balances, arbiter);
        let id = vector::length(&market.orders);
        vector::push_back(&mut market.orders, Order { buyer, seller, arbiter, price, deadline: market.clock + duration, state: 0 });
        vector::push_back(&mut market.journal, Change { order_id: id, actor: buyer, state: 0 });
        id
    }
    public entry fun fund(buyer: &signer, id: u64) acquires Market {
        let actor = signer::address_of(buyer);
        let market = borrow_global_mut<Market>(@demo);
        let order = vector::borrow(&market.orders, id);
        assert!(order.buyer == actor, E_AUTH);
        assert!(order.state == 0 && market.clock < order.deadline, E_STATE);
        let price = order.price;
        let idx = account_index(&market.balances, actor);
        let balance = vector::borrow_mut(&mut market.balances, idx);
        assert!(balance.units >= price, E_BALANCE);
        balance.units = balance.units - price;
        change(market, id, actor, 1);
    }
    public entry fun deliver(seller: &signer, id: u64) acquires Market {
        let actor = signer::address_of(seller);
        let market = borrow_global_mut<Market>(@demo);
        let order = vector::borrow(&market.orders, id);
        assert!(actor == order.seller, E_AUTH);
        assert!(order.state == 1 && market.clock < order.deadline, E_STATE);
        change(market, id, actor, 2);
    }
    fun settle(market: &mut Market, id: u64, actor: address, recipient: address, state: u8) {
        let price = vector::borrow(&market.orders, id).price;
        let idx = account_index(&market.balances, recipient);
        let balance = vector::borrow_mut(&mut market.balances, idx);
        balance.units = balance.units + price;
        change(market, id, actor, state);
    }
    public entry fun confirm(buyer: &signer, id: u64) acquires Market {
        let actor = signer::address_of(buyer);
        let market = borrow_global_mut<Market>(@demo);
        let order = vector::borrow(&market.orders, id);
        assert!(actor == order.buyer, E_AUTH);
        assert!(order.state == 2, E_STATE);
        let seller = order.seller;
        settle(market, id, actor, seller, 3);
    }
    public entry fun cancel(buyer: &signer, id: u64) acquires Market {
        let actor = signer::address_of(buyer);
        let market = borrow_global_mut<Market>(@demo);
        let order = vector::borrow(&market.orders, id);
        assert!(actor == order.buyer, E_AUTH);
        assert!(order.state == 0 || (order.state == 1 && market.clock >= order.deadline), E_STATE);
        if (order.state == 1) { settle(market, id, actor, actor, 4) }
        else { change(market, id, actor, 4) };
    }
    public entry fun dispute(party: &signer, id: u64) acquires Market {
        let actor = signer::address_of(party);
        let market = borrow_global_mut<Market>(@demo);
        let order = vector::borrow(&market.orders, id);
        assert!(actor == order.buyer || actor == order.seller, E_AUTH);
        assert!(order.state == 2, E_STATE);
        change(market, id, actor, 5);
    }
    public entry fun resolve(arbiter: &signer, id: u64, release: bool) acquires Market {
        let actor = signer::address_of(arbiter);
        let market = borrow_global_mut<Market>(@demo);
        let order = vector::borrow(&market.orders, id);
        assert!(actor == order.arbiter, E_AUTH);
        assert!(order.state == 5, E_STATE);
        let recipient = if (release) order.seller else order.buyer;
        settle(market, id, actor, recipient, if (release) 3 else 4);
    }
    public fun balance(owner: address): u64 acquires Market {
        let market = borrow_global<Market>(@demo);
        vector::borrow(&market.balances, account_index(&market.balances, owner)).units
    }
    public fun state(id: u64): u8 acquires Market { vector::borrow(&borrow_global<Market>(@demo).orders, id).state }
    public fun total_units(): u64 acquires Market {
        let market = borrow_global<Market>(@demo);
        let total = 0; let i = 0;
        while (i < vector::length(&market.balances)) { total = total + vector::borrow(&market.balances, i).units; i = i + 1; };
        i = 0;
        while (i < vector::length(&market.orders)) {
            let o = vector::borrow(&market.orders, i);
            if (o.state == 1 || o.state == 2 || o.state == 5) total = total + o.price;
            i = i + 1;
        };
        total
    }
    #[test_only]
    fun setup(admin: &signer) acquires Market {
        initialize(admin); register(admin, @0xB, 1000); register(admin, @0xC, 0); register(admin, @0xD, 0);
    }
    #[test(admin=@demo, buyer=@0xB, seller=@0xC)]
    fun happy_path(admin: signer, buyer: signer, seller: signer) acquires Market {
        setup(&admin); let id = create(&buyer, @0xC, @0xD, 100, 60);
        fund(&buyer, id); assert!(balance(@0xB) == 900 && total_units() == 1000, 100);
        deliver(&seller, id); confirm(&buyer, id);
        assert!(state(id) == 3 && balance(@0xC) == 100 && total_units() == 1000, 101);
    }
    #[test(admin=@demo, buyer=@0xB)]
    fun timeout_refund(admin: signer, buyer: signer) acquires Market {
        setup(&admin); let id = create(&buyer, @0xC, @0xD, 100, 60);
        fund(&buyer, id); advance_clock(&admin, 60); cancel(&buyer, id);
        assert!(state(id) == 4 && balance(@0xB) == 1000 && total_units() == 1000, 102);
    }
    #[test(admin=@demo, buyer=@0xB, seller=@0xC, arbiter=@0xD)]
    fun arbitration_outcomes(admin: signer, buyer: signer, seller: signer, arbiter: signer) acquires Market {
        setup(&admin);
        let id = create(&buyer, @0xC, @0xD, 100, 60); fund(&buyer, id); deliver(&seller, id); dispute(&buyer, id); resolve(&arbiter, id, false);
        assert!(state(id) == 4 && balance(@0xB) == 1000, 103);
        let id = create(&buyer, @0xC, @0xD, 100, 60); fund(&buyer, id); deliver(&seller, id); dispute(&seller, id); resolve(&arbiter, id, true);
        assert!(state(id) == 3 && balance(@0xC) == 100 && total_units() == 1000, 104);
    }
    #[test(admin=@demo, buyer=@0xB)]
    fun unfunded_cancel(admin: signer, buyer: signer) acquires Market {
        setup(&admin); let id = create(&buyer, @0xC, @0xD, 100, 60); cancel(&buyer, id);
        assert!(state(id) == 4 && total_units() == 1000, 105);
    }
    #[test(admin=@demo, buyer=@0xB, stranger=@0xE)]
    #[expected_failure(abort_code=E_AUTH)]
    fun unauthorized_funding(admin: signer, buyer: signer, stranger: signer) acquires Market {
        setup(&admin); let id = create(&buyer, @0xC, @0xD, 100, 60); fund(&stranger, id);
    }
    #[test(admin=@demo, buyer=@0xB)]
    #[expected_failure(abort_code=E_BALANCE)]
    fun insufficient_funds(admin: signer, buyer: signer) acquires Market {
        setup(&admin); let id = create(&buyer, @0xC, @0xD, 1001, 60); fund(&buyer, id);
    }
    #[test(admin=@demo, buyer=@0xB)]
    #[expected_failure(abort_code=E_STATE)]
    fun early_refund_rejected(admin: signer, buyer: signer) acquires Market {
        setup(&admin); let id = create(&buyer, @0xC, @0xD, 100, 60); fund(&buyer, id); cancel(&buyer, id);
    }
    #[test(admin=@demo, buyer=@0xB, seller=@0xC)]
    #[expected_failure(abort_code=E_STATE)]
    fun duplicate_settlement(admin: signer, buyer: signer, seller: signer) acquires Market {
        setup(&admin); let id = create(&buyer, @0xC, @0xD, 100, 60); fund(&buyer, id); deliver(&seller, id); confirm(&buyer, id); confirm(&buyer, id);
    }
    #[test(admin=@demo, buyer=@0xB, seller=@0xC)]
    #[expected_failure(abort_code=E_AUTH)]
    fun unauthorized_arbitration(admin: signer, buyer: signer, seller: signer) acquires Market {
        setup(&admin); let id = create(&buyer, @0xC, @0xD, 100, 60); fund(&buyer, id); deliver(&seller, id); dispute(&buyer, id); resolve(&buyer, id, true);
    }
}
