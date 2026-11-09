# Smart Contract Learning · Solidity / Rust / Move / Vyper 中文学习笔记

Solidity、Rust、Move 与 Vyper 中文学习笔记及可执行业务 Demo。四种实现围绕交付订单托管展开：付款、交付、结算、超时退款与争议仲裁。

**代码入口：[四语言业务 Demo](demos/README.md)** · [业务状态机与资产流](docs/business-flow.md) · [学习路线](docs/learning-path.md)。

Solidity / Vyper 在本地 EVM 执行合约与测试；Rust 是纯标准库状态机；Move 是 Aptos Move 模拟额度资源账本。默认不连接公网、不部署合约，也不读取真实钱包。

## 学习定位

面向区块链开发入门的智能合约语言与机制笔记（smart contract learning resources），围绕 Solidity / EVM、Rust、Move 与 Vyper 建立阅读路径。这里同时提供概念、语法和可执行订单流程，不提供经过审计的生产合约。

先读 [智能合约学习路线](docs/learning-path.md)，再按下表选择语言；需要部署时，应在独立测试工程中固定编译器版本并补齐测试。

## 阅读导航

| 文档 | 主题 |
|---|---|
| [Solidity](Solidity.md) | EVM合约相关学习记录 |
| [Rust](Rust.md) | Rust相关学习记录 |
| [Move](Move.md) | Move相关学习记录 |
| [Vyper](Vyper.md) | Vyper相关学习记录 |
| 本文后续内容 | 智能合约概念、示例和工具记录 |

## 示例使用边界

demos/ 中的新示例提供版本约束、状态机实现和测试。下方历史 SimpleToken 仅用于理解语法：mint 没有访问控制，不能直接视为可发布的代币实现。语言笔记中的旧工具和语法说明仍需结合所用版本核实。

新增业务应同步维护权限、资金守恒、错误行为和测试。具体运行命令及验证记录见 demos/README.md；本地虚拟机通过不等于生产审计通过。

## 原有学习记录

## 智能合约
智能合约是一种运行在区块链上的计算机程序，它能够自动执行、验证和执行合约条款。智能合约最早由密码学家Nick Szabo在1994年提出，但直到以太坊(Ethereum)的出现才真正实现。

智能合约的工作原理如下：
1. **编写和部署**：首先，开发者会使用特定的编程语言（如Solidity）编写智能合约，并将其部署到区块链上。

2. **触发条件**：智能合约包含一系列的规则和条件。当这些条件被满足时，智能合约就会被触发。

3. **自动执行**：一旦触发，智能合约会自动执行预定的操作，无需任何人工干预。

4. **不可更改和透明**：一旦智能合约被部署到区块链上，就无法被修改或删除。此外，所有的交易都是公开透明的，任何人都可以查看。

智能合约在许多领域都有广泛的应用，包括金融服务、供应链管理、版权保护、投票系统等。

## 1、智能合约的主流编程语言主要有以下几种：

1. **Solidity**：这是以太坊智能合约的主要编程语言。它是一种静态类型语言，具有与JavaScript类似的语法，使其对Web开发人员来说易于学习和使用。

2. **Vyper**：这是另一种以太坊智能合约编程语言，旨在使代码更易于理解和审计。它的语法类似于Python。

3. **Chaincode**：这是Hyperledger Fabric（一个开源区块链平台）的智能合约编程语言。Chaincode可以用Go，JavaScript或TypeScript编写。

4. **Rust 和 Ink!**：这是用于Polkadot和Substrate框架的智能合约开发的语言和工具集。

5. **Michelson**：这是Tezos区块链的智能合约语言。它是一种低级堆栈语言，类似于比特币的Script。

6. **Move**：这是Libra（现在称为Diem）区块链的智能合约语言。Move的设计目标是为了提供安全性和可预测性。

7. **Simplicity**：这是用于比特币和其他区块链的智能合约语言。Simplicity是一种低级语言，旨在提供最大的安全性和可分析性。

8. **Scilla**：这是Zilliqa区块链的智能合约语言。Scilla的设计目标是为了提供更高的安全性和更好的形式化验证。

以上就是目前主流的智能合约编程语言，选择哪种语言取决于你的具体需求和你使用的区块链平台。


### 2. 核心特点

- **自动执行**：一旦满足预设条件，合约将自动执行，无需人工干预
- **状态与升级边界**：链上状态按交易改变，代理实现可以通过受控升级替换；不能把“上链”当作无管理员权限的保证
- **透明性**：所有交易和合约状态都是公开可查的
- **去中心化**：不依赖任何中心化机构
- **确定性**：相同的输入总是产生相同的输出
### 3. 主要应用场景
- **去中心化金融(DeFi)**：借贷、交易、保险等
- **数字资产**：代币发行、NFT
- **供应链管理**：追踪商品流转
- **投票系统**：透明、不可篡改的投票机制
- **身份认证**：去中心化身份管理

### 4. 安全考虑
- **重入攻击**：确保状态更新在外部调用之前
- **整数溢出**：Solidity 0.8+ 默认检查整数溢出；审查 unchecked、精度和类型转换，旧版本需另外处理
- **权限控制**：正确设置访问控制
- **Gas优化**：减少不必要的计算和存储
- **代码审计**：部署前进行专业审计

### 5. 智能合约示例
```solidity
// 一个简单的代币合约示例
contract SimpleToken {
    mapping(address => uint256) public balances;
    string public name = "Simple Token";
    string public symbol = "ST";
    
    // 铸造新代币
    function mint(address to, uint256 amount) public {
        balances[to] += amount;
    }
    
    // 转账
    function transfer(address to, uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
}
```
### 6. 开发工具
- **Remix**：在线IDE
- **Truffle**：开发框架
- **Hardhat**：开发环境
- **OpenZeppelin**：安全合约库
- **Etherscan**：合约验证和浏览
### 7. 部署流程
1. 编写合约代码
2. 编译合约
3. 测试合约
4. 部署到测试网
5. 安全审计
6. 部署到主网
### 9. 局限性
- **升级取舍**：不可升级合约修复困难；代理升级则增加管理员权限、存储布局与治理风险
- **Gas成本**：执行需要支付费用
- **性能限制**：受限于区块链性能
- **复杂性**：开发难度较大
- **法律地位**：部分国家法律地位不明确


