# 四语言交付订单 Demo

| 语言 | 实现 | 资产/运行环境 | 入口 |
|---|---|---|---|
| Solidity 0.8.30 | ETH 托管、主动提现、争议仲裁 | Ganache 内存 EVM，Shanghai | [Solidity Demo](solidity/README.md) |
| Vyper 0.4.3 | 同一 EVM 业务接口与状态机 | Ganache 内存 EVM，Shanghai | [Vyper Demo](vyper/README.md) |
| Rust 1.75+ | 多订单账本、错误类型、审计事件 | 纯标准库 CLI，模拟额度 | [Rust Demo](rust/README.md) |
| Aptos Move / CLI 9.6.0 | signer 权限、资源账本、事务回滚 | Move VM 单元测试，模拟额度 | [Move Demo](move/README.md) |

先读 [业务状态机](../docs/business-flow.md)，再对照同一条业务在不同语言中的实现。每套示例覆盖正常交付、未付款取消、超时退款、仲裁放款/退款以及错误角色、重复结算或余额不足。

从仓库根目录准备 Node.js 24 并执行：

```sh
npm ci
npm run test:solidity
# 其他语言还需安装对应工具，见各自 README
npm run test:vyper
npm run test:rust
npm run demo:rust
npm run test:move
```

EVM 测试直接编译源码、部署合约，使用临时账户发送交易，检查状态、余额、退款及重复调用。Ganache 没有 Node 24 原生 uWS 模块时会回退至 JS 实现，不影响本地教学用途。

这些命令不需要 API Key、钱包私钥或公网 RPC。首次安装依赖、下载编译器及 Move 标准库需要网络；业务测试不连接交易所或公网节点。
