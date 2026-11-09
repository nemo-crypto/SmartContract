# Aptos Move 资源账本 Demo

[sources/delivery_escrow.move](sources/delivery_escrow.move) 使用 signer、全局资源、vector 与 abort，模拟多笔交付订单。标准库固定到 aptos-cli-v9.6.0 标签，命名地址 demo 为测试地址 0xA。

安装官方 Aptos CLI 9.6.0 后，在仓库根目录运行：

```sh
aptos --version
aptos move test --package-dir demos/move
```

首次执行会通过 Git 获取 Move 标准库；测试在本地 Move VM 中运行，不需要 aptos init、账户配置或链上部署。

业务过程：管理员 initialize / register 初始化模拟余额，买方 create / fund，卖方 deliver，买方 confirm 结算；未付款取消或超时退款由 cancel 处理，争议使用 dispute / resolve。管理员 advance_clock 单调推进教学时间。

测试覆盖交付结算、两种仲裁结果、未付款取消、超时退款、未经授权付款、提前退款、余额不足、重复结算和越权仲裁。journal 记录状态变化，total_units 检查模拟额度守恒。

**这不是 Aptos Coin 或 FungibleAsset 托管合约。** register 由管理员显式发行模拟额度，clock 不是链上时间。接入真实资产前必须替换余额和时间实现，并补齐资源权限、存取及资产守恒验证；不应把本示例直接部署为资金服务。
