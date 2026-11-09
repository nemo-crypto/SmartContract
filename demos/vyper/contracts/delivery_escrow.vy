#pragma version 0.4.3

# 与 Solidity 示例共享同一业务状态机，便于对照权限与资产流。
event Transition:
    status: uint256
    actor: address

event Withdrawn:
    recipient: address
    amount: uint256

buyer: public(address)
seller: public(address)
arbiter: public(address)
price: public(uint256)
deadline: public(uint256)
status: public(uint256)
credits: public(HashMap[address, uint256])

@deploy
def __init__(seller_: address, arbiter_: address, price_: uint256, duration: uint256):
    assert seller_ != empty(address) and arbiter_ != empty(address), "zero address"
    assert msg.sender != seller_ and msg.sender != arbiter_ and seller_ != arbiter_, "distinct roles"
    assert price_ > 0 and duration > 0 and duration <= 2592000, "invalid terms"
    self.buyer = msg.sender
    self.seller = seller_
    self.arbiter = arbiter_
    self.price = price_
    self.deadline = block.timestamp + duration

@internal
def transition(next_status: uint256):
    self.status = next_status
    log Transition(status=next_status, actor=msg.sender)

@external
@payable
def fund():
    assert msg.sender == self.buyer, "buyer only"
    assert self.status == 0 and block.timestamp < self.deadline, "invalid state/time"
    assert msg.value == self.price, "exact payment required"
    self.transition(1)

@external
def deliver():
    assert msg.sender == self.seller, "seller only"
    assert self.status == 1 and block.timestamp < self.deadline, "invalid state/time"
    self.transition(2)

@external
def confirm():
    assert msg.sender == self.buyer and self.status == 2, "invalid caller/state"
    self.credits[self.seller] += self.price
    self.transition(3)

@external
def cancel():
    assert msg.sender == self.buyer, "buyer only"
    assert self.status == 0 or (self.status == 1 and block.timestamp >= self.deadline), "cannot cancel"
    if self.status == 1:
        self.credits[self.buyer] += self.price
    self.transition(4)

@external
def dispute():
    assert (msg.sender == self.buyer or msg.sender == self.seller) and self.status == 2, "invalid caller/state"
    self.transition(5)

@external
def resolve(releaseToSeller: bool):
    assert msg.sender == self.arbiter and self.status == 5, "invalid caller/state"
    if releaseToSeller:
        self.credits[self.seller] += self.price
        self.transition(3)
    else:
        self.credits[self.buyer] += self.price
        self.transition(4)

@external
@nonreentrant
def withdraw():
    amount: uint256 = self.credits[msg.sender]
    assert amount > 0, "no credit"
    self.credits[msg.sender] = 0
    raw_call(msg.sender, b"", value=amount)
    log Withdrawn(recipient=msg.sender, amount=amount)
