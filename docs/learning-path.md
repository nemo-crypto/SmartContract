# 智能合约开发学习路线

本仓库是中文学习笔记，覆盖 Solidity、Rust、Move 和 Vyper。检索入口对应真实资料，不代表这些语言的合约已编译、部署或通过审计。

| 学习目标与检索词 | 阅读入口 | 练习方向 |
|---|---|---|
| Solidity / EVM / smart contracts | [Solidity](../Solidity.md) | 分清 storage、memory、calldata，解释权限检查与外部调用 |
| Rust / blockchain programming | [Rust](../Rust.md) | 练习所有权、借用、Result；区分 Rust 语言与具体链的运行时 |
| Move / resource-oriented programming | [Move](../Move.md) | 比较资源所有权、能力与访问控制；区分不同链的 Move 方言 |
| Vyper / Ethereum | [Vyper](../Vyper.md) | 对照 Solidity 阅读状态变量、函数可见性和事件 |

## 从笔记到可执行工程

1. 选择目标链、语言与编译器版本，不把不同版本语法混在一个工程中。
2. 从最小示例开始，记录输入、状态变化、错误条件与可见权限。
3. 在独立测试项目中补充正常流程、拒绝未授权操作、边界值及重复调用的断言。
4. 检查外部调用、重入、整数精度、升级权限和事件记录，再使用测试网演练。
5. 记录编译器、依赖、部署参数和验证结果。生产使用仍需针对业务做独立安全评估。

根 README 中的 SimpleToken 仅用于解释 mapping 与状态更新：mint 没有访问控制，没有 ERC-20 接口兼容保证，不能作为代币发行模板。新的可执行实现位于 [demos](../demos/README.md)，使用 solc + 本地 EVM、Vyper、Cargo 和 Aptos Move 单元测试；不提供部署成功或审计通过的承诺。
