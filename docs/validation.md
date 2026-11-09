# 本地验证记录

验证日期：2026-11-09，macOS arm64。所有业务测试使用临时本地环境，没有连接公网 RPC、交易所或真实钱包。

| 示例 | 工具版本 | 验证 | 结果 |
|---|---|---|---|
| Solidity | solc 0.8.30、Node.js 24、Ganache 7.9.2、Ethers 6.16.0 | 编译后部署至内存 EVM，运行完整业务断言 | 6 / 6 通过 |
| Vyper | Vyper 0.4.3、Python 3.12.16，同一 EVM 环境 | 编译后运行与 Solidity 相同的业务测试 | 6 / 6 通过 |
| Move | Aptos CLI 9.6.0，标准库固定同名版本标签 | 本地 Move VM 单元测试 | 9 / 9 通过 |
| Rust | Rust / Cargo 1.99.1，纯标准库 | cargo test --offline 与 CLI 演示 | 5 / 5 通过；最终 buyer=900、seller=100、total=1000 |

合计 26 项测试。覆盖完整交付结算、未付款取消、超时退款、两种仲裁结果，以及越权、错误金额、余额不足、重复结算或提现等场景。不同语言的失败语义通过各自测试断言；不把“交易已广播”误当作“交易执行成功”，EVM 负向测试等待最终交易收据。

## 可复现命令

在仓库根目录，准备各语言 README 指定的工具后执行：

```sh
npm ci
npm run test:solidity
VYPER_BIN="$PWD/.venv/bin/vyper" npm run test:vyper
cargo test --locked --offline --manifest-path demos/rust/Cargo.toml
cargo run --locked --offline --manifest-path demos/rust/Cargo.toml
aptos move test --package-dir demos/move
```

本次 Move 使用已下载的固定版本标准库，并添加 --skip-fetch-latest-git-deps，避免重复获取相同依赖。Node 依赖由 package-lock.json 固定；Vyper 环境由 requirements-lock.txt 固定。Ganache 内部的 macOS fsevents 标为可选依赖，已通过 npm ci --dry-run --ignore-scripts --os=linux --cpu=x64 检查跨平台安装计划。

[GitHub Actions](../.github/workflows/demos.yml) 配置了 EVM、Rust、Move 三个独立任务。本表记录的是本地执行结果，不代替远端 CI 状态、真实链部署验证或安全审计。

## 验证范围

Rust 和 Move 使用模拟额度；Move 的教学时钟由管理员推进。EVM 测试在 Shanghai 虚拟机运行，不评估真实网络 Gas 成本、交易排序、升级治理或恶意仲裁者风险。交付后确认与争议仲裁没有超时兜底，限制与后续练习见 [业务流程](business-flow.md)。
