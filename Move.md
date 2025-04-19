## Move
### 1. 开发环境搭建

1. **安装 Move CLI**
```bash
# 安装 Move CLI (以 Aptos 为例)
cargo install --git https://github.com/aptos-labs/aptos-core.git aptos
```

2. **创建新项目**
```bash
# 创建新的 Move 项目
aptos move init --name my_project
```

### 2. 项目结构
典型的 Move 项目结构如下：
```
my_project/
├── Move.toml          # 项目配置文件
├── sources/           # 源代码目录
│   └── main.move     # 主合约文件
└── tests/            # 测试文件目录
```

### 3. 编写合约
示例合约 `main.move`:
```
module my_project::main {
    use std::signer;
    
    struct Counter has key {
        value: u64
    }
    
    public fun initialize(account: &signer) {
        move_to(account, Counter { value: 0 });
    }
    
    public fun increment(account: &signer) acquires Counter {
        let counter = borrow_global_mut<Counter>(signer::address_of(account));
        counter.value = counter.value + 1;
    }
    
    public fun get_value(account: &signer): u64 acquires Counter {
        borrow_global<Counter>(signer::address_of(account)).value
    }
}
```

### 4. 编译合约

```bash
# 编译合约
aptos move compile
```

### 5. 测试合约
1. **编写测试**
```move
#[test(account = @0x1)]
fun test_increment(account: &signer) {
    initialize(account);
    increment(account);
    assert!(get_value(account) == 1, 0);
}
```

2. **运行测试**
```bash
aptos move test
```

### 6. 部署合约
1. **配置网络**
```bash
# 设置测试网
aptos config set-global-config --config-type testnet
```

2. **创建账户**
```bash
# 创建新账户
aptos account create
```

3. **部署合约**
```bash
# 部署合约到测试网
aptos move publish --named-addresses my_project=0x123
```

### 7. 与合约交互
1. **调用合约函数**
```bash
# 调用 initialize 函数
aptos move run --function-id 0x123::main::initialize

# 调用 increment 函数
aptos move run --function-id 0x123::main::increment
```

### 8. 最佳实践
1. **安全性考虑**
- 使用 `signer` 类型验证调用者身份
- 实现适当的访问控制
- 进行充分的错误处理
2. **性能优化**
- 最小化存储操作
- 使用批量操作
- 避免不必要的计算
3. **代码组织**
- 模块化设计
- 清晰的文档注释
- 完整的测试覆盖
### 9. 调试和监控
1. **查看交易**
```bash
# 查看交易详情
aptos transaction show <tx_hash>
```

2. **查看账户状态**
```bash
# 查看账户资源
aptos account list --account 0x123
```

### 10. 常见问题解决
1. **编译错误**
- 检查 Move.toml 配置
- 确保依赖项正确
- 验证语法错误
2. **部署错误**
- 检查账户余额
- 验证网络连接
- 确认权限设置
3. **运行时错误**
- 检查资源访问权限
- 验证函数参数
- 确认前置条件
