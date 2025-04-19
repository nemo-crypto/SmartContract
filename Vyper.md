## Vyper

Vyper 是一种面向合约的 Python 编程语言，专为以太坊虚拟机(EVM)设计。它的主要特点是：
- 语法简单，类似 Python
- 强类型系统
- 安全性优先
- 可读性强
- 不支持继承和递归
### 2. 开发环境搭建
1. 安装 Python (推荐 3.7+)
2. 安装 Vyper:
```bash
pip install vyper
```

3. 安装开发工具:
```bash
pip install eth-brownie  # 开发框架
pip install web3         # 以太坊交互
```

### 3. 编写智能合约
创建一个简单的代币合约示例 `Token.vy`:
```
# @version 0.3.7

# 事件定义
event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    value: uint256

# 状态变量
name: public(String[32])
symbol: public(String[32])
decimals: public(uint8)
totalSupply: public(uint256)
balanceOf: public(HashMap[address, uint256])

@external
def __init__(_name: String[32], _symbol: String[32], _decimals: uint8, _totalSupply: uint256):
    self.name = _name
    self.symbol = _symbol
    self.decimals = _decimals
    self.totalSupply = _totalSupply
    self.balanceOf[msg.sender] = _totalSupply

@external
def transfer(_to: address, _value: uint256) -> bool:
    assert self.balanceOf[msg.sender] >= _value
    self.balanceOf[msg.sender] -= _value
    self.balanceOf[_to] += _value
    log Transfer(msg.sender, _to, _value)
    return True
```

### 4. 编译合约
使用 Vyper 编译器编译合约:
```
vyper contracts/Token.vy
```
或者使用 Brownie 编译:
```
brownie compile
```

### 5. 测试合约
创建测试文件 `tests/test_token.py`:
```
from brownie import Token, accounts

def test_token():
    # 部署合约
    token = Token.deploy("Test Token", "TT", 18, 1000000, {'from': accounts[0]})
    
    # 测试初始状态
    assert token.name() == "Test Token"
    assert token.totalSupply() == 1000000
    
    # 测试转账
    token.transfer(accounts[1], 100, {'from': accounts[0]})
    assert token.balanceOf(accounts[1]) == 100
```
运行测试:
```
brownie test
```

### 6. 部署合约
1. 配置网络 (以 Goerli 测试网为例):
```python:brownie-config.yaml
networks:
  default: goerli
  goerli:
    host: https://goerli.infura.io/v3/YOUR-PROJECT-ID
    chainid: 5
```

2. 部署脚本 `scripts/deploy.py`:
```python:scripts/deploy.py
from brownie import Token, accounts, network

def main():
    # 连接到网络
    network.connect('goerli')
    
    # 获取账户
    account = accounts.load('my_wallet')
    
    # 部署合约
    token = Token.deploy(
        "Test Token",
        "TT",
        18,
        1000000,
        {'from': account}
    )
    
    print(f"Token deployed at: {token.address}")
```

3. 部署命令:
```
brownie run scripts/deploy.py
```
### 7. 与合约交互
使用 Web3.py 与已部署的合约交互:
```
from web3 import Web3
from vyper import compile_code

# 连接以太坊节点
w3 = Web3(Web3.HTTPProvider('https://goerli.infura.io/v3/YOUR-PROJECT-ID'))

# 合约地址和 ABI
contract_address = "0x..."
contract_abi = [...]  # 从编译后的合约获取

# 创建合约实例
contract = w3.eth.contract(address=contract_address, abi=contract_abi)

# 调用合约方法
balance = contract.functions.balanceOf(w3.eth.accounts[0]).call()
print(f"Balance: {balance}")
```
### 8. 安全注意事项
1. 整数溢出检查
2. 重入攻击防护
3. 权限控制
4. 事件记录
5. 代码审计
### 9. 最佳实践
1. 使用最新版本的 Vyper
2. 编写完整的测试用例
3. 进行代码审计
4. 使用标准库函数
5. 保持代码简洁
6. 添加适当的注释
7. 实现错误处理机制
### 10. 常用工具和资源
1. Vyper 官方文档: https://vyper.readthedocs.io/
2. Brownie 文档: https://eth-brownie.readthedocs.io/
3. Remix IDE: https://remix.ethereum.org/
4. Etherscan: https://etherscan.io/
5. OpenZeppelin Contracts: https://openzeppelin.com/contracts/
