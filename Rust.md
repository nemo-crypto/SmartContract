## Rust

### 1. 开发环境搭建
1. **安装 Rust**
```bash
# 使用 rustup 安装 Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 验证安装
rustc --version
cargo --version
```

2. **IDE 配置**
- 推荐使用 VS Code + Rust Analyzer 插件
- 其他可选：IntelliJ IDEA + Rust 插件
### 2. 项目开发
1. **创建新项目**
```bash
# 创建二进制项目
cargo new my_project

# 创建库项目
cargo new --lib my_lib
```

2. **项目结构**
```
my_project/
├── Cargo.toml    # 项目配置和依赖
├── src/
│   ├── main.rs   # 主程序入口
│   └── lib.rs    # 库文件（如果存在）
└── target/       # 编译输出目录
```

3. **依赖管理**
```toml
# Cargo.toml 示例
[package]
name = "my_project"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1.0", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
```

### 3. 开发实践
1. **代码组织**
- 使用模块系统组织代码
- 遵循 Rust 的命名规范
- 使用 `cargo fmt` 和 `cargo clippy` 保持代码质量
2. **测试**
```rust
// 单元测试
#[cfg(test)]
mod tests {
    #[test]
    fn test_example() {
        assert_eq!(2 + 2, 4);
    }
}

// 运行测试
cargo test
```

3. **文档**
```
/// 函数文档示例
///
/// # Examples
///
/// ```
/// let result = add(2, 2);
/// assert_eq!(result, 4);
/// ```
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}
```
### 4. 构建和优化
1. **发布构建**
```bash
# 优化构建
cargo build --release

# 检查优化后的二进制大小
cargo bloat --release
```

2. **性能优化**
- 使用 `#[inline]` 优化关键函数
- 使用 `unsafe` 块进行性能关键代码优化
- 使用 `cargo flamegraph` 进行性能分析
### 5. 部署
1. **Docker 部署**
```dockerfile
# 多阶段构建
FROM rust:1.70 as builder
WORKDIR /usr/src/app
COPY . .
RUN cargo build --release

FROM debian:buster-slim
COPY --from=builder /usr/src/app/target/release/my_app /usr/local/bin/my_app
CMD ["my_app"]
```

2. **系统服务部署**
```systemd
# /etc/systemd/system/my_app.service
[Unit]
Description=My Rust Application
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/my_app
ExecStart=/usr/local/bin/my_app
Restart=always

[Install]
WantedBy=multi-user.target
```

### 6. 监控和日志
1. **日志配置**
```rust
use log::{info, error};
use env_logger;

fn main() {
    env_logger::init();
    info!("Application started");
    // ...
}
```

2. **指标收集**
```rust
use metrics::{counter, gauge};
use metrics_exporter_prometheus::PrometheusBuilder;

fn setup_metrics() {
    PrometheusBuilder::new()
        .install()
        .expect("Failed to install metrics recorder");
}
```

### 7. 持续集成/持续部署 (CI/CD)
1. **GitHub Actions 示例**
```yaml
name: Rust CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Build
      run: cargo build --release
    - name: Test
      run: cargo test
    - name: Deploy
      run: |
        scp target/release/my_app user@server:/opt/my_app
        ssh user@server "systemctl restart my_app"
```

### 8. 安全考虑
1. **依赖安全**
```bash
# 检查依赖漏洞
cargo audit
```

2. **代码安全**
- 使用 `#![forbid(unsafe_code)]` 限制不安全代码
- 使用 `cargo-geiger` 检查不安全代码使用情况
### 9. 性能监控
1. **使用 Prometheus + Grafana**
```rust
use prometheus::{Counter, Registry};

let counter = Counter::new("requests_total", "Total number of requests").unwrap();
let registry = Registry::new();
registry.register(Box::new(counter.clone())).unwrap();
```

### 10. 错误处理

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    #[error("Database error: {0}")]
    Database(String),
}

fn main() -> Result<(), AppError> {
    // 错误处理代码
    Ok(())
}
```

```
