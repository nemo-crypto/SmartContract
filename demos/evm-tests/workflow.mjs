import test from 'node:test';
import assert from 'node:assert/strict';
import ganache from 'ganache';
import { BrowserProvider, ContractFactory, parseEther } from 'ethers';

// 交易广播成功不代表执行成功：负向用例必须等待收据中的回滚结果。
async function rejects(action) {
  await assert.rejects(async () => {
    const result = await action();
    if (result.wait) await result.wait();
    if (result.waitForDeployment) await result.waitForDeployment();
  });
}
export function workflowTests(name, artifact) {
  const price = parseEther('1');
  async function fixture(t, duration = 3600) {
    // 确定性临时账户仅存在内存，不连接 RPC、不读取真实钱包。
    const rpc = ganache.provider({ logging: { quiet: true }, wallet: { deterministic: true }, chain: { hardfork: 'shanghai' } });
    const provider = new BrowserProvider(rpc, undefined, { cacheTimeout: -1 }); provider.pollingInterval = 10;
    t.after(async () => { provider.destroy(); await rpc.disconnect(); });
    const [buyer, seller, arbiter, stranger] = await Promise.all([0, 1, 2, 3].map(i => provider.getSigner(i)));
    const factory = new ContractFactory(artifact.abi, artifact.bytecode, buyer);
    const escrow = await factory.deploy(await seller.getAddress(), await arbiter.getAddress(), price, duration);
    await escrow.waitForDeployment();
    const send = async promise => (await promise).wait();
    const balance = async () => BigInt(await rpc.request({ method: 'eth_getBalance', params: [await escrow.getAddress(), 'latest'] }));
    return { rpc, buyer, seller, arbiter, stranger, escrow, send, balance, factory };
  }
  test(`${name}: 付款 → 交付 → 买方确认 → 卖方提现`, async t => {
    const { escrow: e, seller, send, balance } = await fixture(t);
    await send(e.fund({ value: price })); assert.equal(await balance(), price);
    await send(e.connect(seller).deliver()); await send(e.confirm());
    assert.equal(await e.status(), 3n); assert.equal(await e.credits(await seller.getAddress()), price);
    await send(e.connect(seller).withdraw()); assert.equal(await balance(), 0n);
    assert.equal(await e.credits(await seller.getAddress()), 0n);
    await rejects(() => e.connect(seller).withdraw());
    await rejects(() => e.confirm());
  });
  test(`${name}: 错误金额、越权与重复付款被拒绝且余额不变`, async t => {
    const { escrow: e, stranger, seller, send, balance } = await fixture(t);
    await rejects(() => e.connect(stranger).fund({ value: price }));
    await rejects(() => e.fund({ value: price - 1n }));
    await rejects(() => e.confirm());
    assert.equal(await balance(), 0n);
    await send(e.fund({ value: price }));
    await rejects(() => e.fund({ value: price }));
    await rejects(() => e.connect(stranger).deliver());
    await rejects(() => e.cancel());
    await send(e.connect(seller).deliver());
    await rejects(() => e.connect(stranger).confirm());
    assert.equal(await balance(), price); assert.equal(await e.status(), 2n);
  });
  test(`${name}: 交付超时退款，禁止过期交付`, async t => {
    const { rpc, escrow: e, buyer, seller, send, balance } = await fixture(t, 60);
    await send(e.fund({ value: price }));
    await rpc.request({ method: 'evm_increaseTime', params: [61] }); await rpc.request({ method: 'evm_mine', params: [] });
    await rejects(() => e.connect(seller).deliver());
    await send(e.cancel()); assert.equal(await e.status(), 4n);
    assert.equal(await e.credits(await buyer.getAddress()), price);
    await send(e.withdraw()); assert.equal(await balance(), 0n);
  });
  for (const release of [true, false]) test(`${name}: 争议仲裁${release ? '放款' : '退款'}`, async t => {
    const { escrow: e, buyer, seller, arbiter, stranger, send, balance } = await fixture(t);
    await send(e.fund({ value: price })); await send(e.connect(seller).deliver());
    await rejects(() => e.connect(stranger).dispute()); await send(e.dispute());
    await rejects(() => e.confirm()); await rejects(() => e.resolve(release));
    await send(e.connect(arbiter).resolve(release));
    const recipient = release ? seller : buyer;
    assert.equal(await e.status(), release ? 3n : 4n);
    assert.equal(await e.credits(await recipient.getAddress()), price);
    await send(e.connect(recipient).withdraw()); assert.equal(await balance(), 0n);
    await rejects(() => e.connect(arbiter).resolve(release));
  });
  test(`${name}: 未付款订单取消及无效角色拒绝`, async t => {
    const { escrow: e, buyer, arbiter, factory, send } = await fixture(t);
    await send(e.cancel()); assert.equal(await e.status(), 4n);
    await rejects(() => e.fund({ value: price }));
    const buyerAddress = await buyer.getAddress(); const arbiterAddress = await arbiter.getAddress();
    await rejects(() => factory.deploy(buyerAddress, arbiterAddress, price, 3600));
  });
}
