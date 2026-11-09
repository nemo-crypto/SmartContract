# Solidity / EVM 订单托管 Demo

[DeliveryEscrow.sol](contracts/DeliveryEscrow.sol) 使用 Solidity 0.8.30，三种角色分别为买方、卖方、仲裁者。构造器创建订单，买方 fund 精确支付 ETH；卖方 deliver，买方 confirm 后卖方 withdraw。超时未交付由买方 cancel + withdraw；已交付争议由任意交易方 dispute，仲裁者 resolve 决定放款或退款。

在仓库根目录运行：

```sh
npm ci
npm run test:solidity
```

编译器通过锁文件安装，测试使用 Ganache 内存 EVM，不部署公网。输出包含每个完整业务场景的通过/失败状态。

阅读顺序：构造器角色校验 → fund/deliver 状态约束 → confirm/cancel/resolve 记账 → withdraw 的先清零后转账 → [共享业务测试](../evm-tests/workflow.mjs)。事件记录状态变化与提现。

测试覆盖完整结算、越权、错误金额、重复付款、过期退款、两种仲裁结果、重复结算与重复提现。需要比较另一种合约语法时，使用相同测试验证 [Vyper 实现](../vyper/README.md)。

示例没有仲裁超时机制或审计结论，详见 [业务边界](../../docs/business-flow.md)。不要使用真实资产。
