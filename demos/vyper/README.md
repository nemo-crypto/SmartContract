# Vyper / Ethereum 订单托管 Demo

[delivery_escrow.vy](contracts/delivery_escrow.vy) 与 Solidity 示例共享 fund、deliver、confirm、cancel、dispute、resolve、withdraw 接口。使用 Vyper 0.4.3 的 @deploy、@nonreentrant、事件与 HashMap，练习可读合约、角色隔离及主动提现。

在仓库根目录使用 Python 3.12 与 Node.js 24：

```sh
python3.12 -m venv .venv
.venv/bin/python -m pip install -r demos/vyper/requirements-lock.txt
npm ci
VYPER_BIN="$PWD/.venv/bin/vyper" npm run test:vyper
```

测试编译为 Shanghai EVM 字节码，并运行与 Solidity 相同的完整业务断言。VYPER_BIN 只用于指定编译器路径，默认查找 PATH 中的 vyper。

业务流程：买方精确付款 → 卖方交付 → 买方确认 → 卖方提现；未按期交付走取消退款；交付后争议冻结资金，由仲裁者判定放款/退款。非法角色、金额、状态及重复结算会被拒绝。

与 Solidity 对照阅读时，关注 Vyper 的装饰器、显式 self 状态、内部 transition 函数和非重入锁。完整权限表与当前限制见 [业务状态机](../../docs/business-flow.md)。
