# 验证记录

日期：2026-10-04；执行环境：Linux x86_64；Rust stable 1.99.0。

已通过：

- 5 项 C ABI/真实核心回归：部分候选消耗与剩余拼音、英文释义、过期候选选择、边界退格、原样上屏与清空、空指针失败处理。
- 随包 `.qj` 数据端到端测试：开发 / 你好 / 工作 / 学习均返回中文候选和非空英文释义。
- `cargo fmt -p qingjian-ios --check`。
- `cargo clippy --locked -p qingjian-ios --all-targets -- -D warnings`。
- `cargo check --locked -p qingjian-ios --lib --target aarch64-apple-ios`。
- `cargo build --locked --release -p qingjian-ios --lib --target aarch64-apple-ios`：iPhone ARM64 核心静态库已生成，约 42 MiB；未经过 Apple 系统框架最终链接。
- `.qj` 词库和释义容器生成：约 3.4 MiB + 5.6 MiB。
- 8 个 Swift 文件通过 tree-sitter Swift 语法解析；这不等于 Apple SDK 的类型检查。
- 构建 shell 脚本语法、Python 打包脚本语法与 Info.plist 结构。

云端模拟器构建只验证 runner 对应的架构（Apple Silicon 为 ARM64，Intel 为 x86_64）；Xcode 与 Rust 静态库使用相同架构。iPhone 包单独构建 ARM64。

尚未完成，不能据此宣称已成功安装：

- macOS/Xcode 的 Swift 类型检查、UIKit 编译与最终系统框架链接。
- 模拟器加载键盘扩展。
- 用当前 iOS 和免费账号签名后安装，键盘在备忘录/微信里的实际表现。
- 真机内存峰值、冷启动速度、布局和连续快速输入测试。

本交付是源码和构建配置，不是已经签名、经过真机验收的 IPA。
