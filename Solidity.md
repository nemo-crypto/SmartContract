## Solidity

### 1. 开发环境搭建
1. **安装必要工具**：
   - Node.js
   - npm (Node.js 包管理器)
   - Git
2. **安装开发框架**：
```bash
# 安装 Truffle 框架
npm install -g truffle

# 安装 Ganache (本地测试网络)
npm install -g ganache
```

3. **IDE 选择**：
   - Remix IDE (在线 IDE)
   - VS Code + Solidity 插件
   - IntelliJ IDEA + Solidity 插件
### 2. 项目初始化

```bash
# 创建新项目
mkdir my-contract
cd my-contract
truffle init
```

项目结构：
```
my-contract/
├── contracts/        # 智能合约文件
├── migrations/       # 部署脚本
├── test/            # 测试文件
└── truffle-config.js # 配置文件
```
### 3. 编写智能合约

```solidity:contracts/MyContract.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyContract {
    uint256 public value;
    
    constructor() {
        value = 0;
    }
    
    function setValue(uint256 _value) public {
        value = _value;
    }
    
    function getValue() public view returns (uint256) {
        return value;
    }
}
```

### 4. 编写部署脚本

```javascript:migrations/2_deploy_contracts.js
const MyContract = artifacts.require("MyContract");

module.exports = function(deployer) {
    deployer.deploy(MyContract);
};
```

### 5. 配置网络

```javascript:truffle-config.js
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*"
    },
    testnet: {
      provider: () => new HDWalletProvider(mnemonic, `https://ropsten.infura.io/v3/${infuraKey}`),
      network_id: 3,
      gas: 5500000
    },
    mainnet: {
      provider: () => new HDWalletProvider(mnemonic, `https://mainnet.infura.io/v3/${infuraKey}`),
      network_id: 1,
      gas: 5500000
    }
  }
};
```

### 6. 本地测试
1. **启动 Ganache**：
```bash
ganache
```

2. **编译合约**：
```bash
truffle compile
```

3. **部署到本地网络**：
```bash
truffle migrate --network development
```

4. **运行测试**：
```bash
truffle test
```

### 7. 部署到测试网/主网
1. **准备钱包**：
   - 创建钱包
   - 获取助记词
   - 确保有足够的测试币/ETH
2. **配置环境变量**：
```bash
# .env 文件
MNEMONIC="your wallet mnemonic"
INFURA_KEY="your infura key"
```

3. **部署到测试网**：
```bash
truffle migrate --network testnet
```

4. **部署到主网**：
```bash
truffle migrate --network mainnet
```

### 8. 验证合约
1. **在区块浏览器上验证**：
   - Etherscan (以太坊)
   - BscScan (BSC)
   - 其他链的区块浏览器
2. **验证合约代码**：
   - 上传源代码
   - 验证编译器版本
   - 验证优化设置
### 9. 安全注意事项
1. **代码审计**：
   - 使用自动化工具检查
   - 进行人工代码审查
   - 考虑第三方审计
2. **常见安全实践**：
   - 使用 SafeMath 库
   - 实现访问控制
   - 避免重入攻击
   - 正确处理异常
### 10. 维护和升级
1. **监控合约**：
   - 使用区块浏览器
   - 设置事件监听
   - 监控异常交易
2. **升级策略**：
   - 使用代理模式
   - 实现升级机制
   - 保留回滚选项
### 11. 常用工具和资源
1. **开发工具**：
   - Hardhat
   - OpenZeppelin
   - Web3.js/ethers.js
2. **测试工具**：
   - Mocha
   - Chai
   - Waffle
3. **安全工具**：
   - Slither
   - Mythril
   - Oyente
4. **区块浏览器**：
   - Etherscan
   - BscScan
   - Polygonscan
### 12. 最佳实践
1. **代码规范**：
   - 遵循 Solidity 风格指南
   - 使用有意义的变量名
   - 添加适当的注释
2. **测试覆盖**：
   - 编写单元测试
   - 进行集成测试
   - 模拟各种场景
3. **文档编写**：
   - 编写技术文档
   - 提供用户指南
   - 记录已知问题
