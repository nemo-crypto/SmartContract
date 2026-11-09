// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/// @notice 单笔交付订单教学合约。真实业务还需审计与争议治理设计。
contract DeliveryEscrow {
    address public immutable buyer;
    address public immutable seller;
    address public immutable arbiter;
    uint256 public immutable price;
    uint256 public immutable deadline;
    // 0 Created, 1 Funded, 2 Delivered, 3 Completed, 4 Cancelled, 5 Disputed
    uint256 public status;
    mapping(address => uint256) public credits;
    bool private withdrawing;
    event Transition(uint256 status, address actor);
    event Withdrawn(address recipient, uint256 amount);

    constructor(address seller_, address arbiter_, uint256 price_, uint256 duration) {
        require(seller_ != address(0) && arbiter_ != address(0), "zero address");
        require(msg.sender != seller_ && msg.sender != arbiter_ && seller_ != arbiter_, "distinct roles");
        require(price_ > 0 && duration > 0 && duration <= 30 days, "invalid terms");
        buyer = msg.sender;
        seller = seller_;
        arbiter = arbiter_;
        price = price_;
        deadline = block.timestamp + duration;
    }
    function fund() external payable {
        require(msg.sender == buyer, "buyer only");
        require(status == 0 && block.timestamp < deadline, "invalid state/time");
        require(msg.value == price, "exact payment required");
        transition(1);
    }
    function deliver() external {
        require(msg.sender == seller, "seller only");
        require(status == 1 && block.timestamp < deadline, "invalid state/time");
        transition(2);
    }
    function confirm() external {
        require(msg.sender == buyer && status == 2, "invalid caller/state");
        credits[seller] += price;
        transition(3);
    }
    function cancel() external {
        require(msg.sender == buyer, "buyer only");
        require(status == 0 || (status == 1 && block.timestamp >= deadline), "cannot cancel");
        if (status == 1) credits[buyer] += price;
        transition(4);
    }
    function dispute() external {
        require((msg.sender == buyer || msg.sender == seller) && status == 2, "invalid caller/state");
        transition(5);
    }
    function resolve(bool releaseToSeller) external {
        require(msg.sender == arbiter && status == 5, "invalid caller/state");
        credits[releaseToSeller ? seller : buyer] += price;
        transition(releaseToSeller ? 3 : 4);
    }
    // 先记账、后主动提现；失败回滚，不在确认/仲裁流程中调用收款方。
    function withdraw() external {
        require(!withdrawing, "reentrant");
        uint256 amount = credits[msg.sender];
        require(amount > 0, "no credit");
        withdrawing = true;
        credits[msg.sender] = 0;
        (bool ok,) = payable(msg.sender).call{value: amount}("");
        require(ok, "transfer failed");
        withdrawing = false;
        emit Withdrawn(msg.sender, amount);
    }
    function transition(uint256 next) private {
        status = next;
        emit Transition(next, msg.sender);
    }
}
