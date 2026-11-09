# Rust 订单状态机与模拟账本 Demo

纯 Rust 标准库实现多订单 Market，展示领域模型、Result 错误处理、BTreeMap 余额、事件记录与单元测试。**这是链下业务模拟，不是 Solana / Polkadot 合约，也没有签名认证或真实转账。**

安装 Rust 1.75+ 后，在仓库根目录运行：

```sh
cargo test --manifest-path demos/rust/Cargo.toml
cargo run --manifest-path demos/rust/Cargo.toml
```

CLI 连续演示三笔订单：正常交付结算、超时退款、争议退款，最终打印 buyer=900、seller=100、total=1000。每次运行重新初始化内存数据，不写数据库。

[src/lib.rs](src/lib.rs) 提供 create → fund → deliver → confirm 主线，以及 cancel、dispute、resolve 分支；src/main.rs 是消费方示例。时间与账户作为显式参数，便于测试边界，但不是生产身份或可信时间来源。

测试验证资金守恒、失败操作不改变状态、余额不足、越权、期限边界、重复结算、两种仲裁结果及整数溢出。添加数据库时应保持领域模型独立，并在持久化层建立同等原子性保证。
