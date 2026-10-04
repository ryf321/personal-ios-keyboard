# 验证记录

日期：2026-10-04；本地环境：Linux x86_64；Rust stable 1.99.0。

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

## 云端编译与下载产物检查

- 运行记录：<https://github.com/ryf321/personal-ios-keyboard/actions/runs/37204153245>；源码 commit `bc28709eb74a58b63def75e36956b757c1716142`。
- GitHub 标准 macOS runner：macOS 15.7.9 ARM64、Xcode 16.4、iOS SDK 18.5。
- 核心测试、资源测试、格式检查和 Clippy 全部通过。
- ARM64 模拟器主 App 与键盘扩展的 Swift 类型检查、UIKit 编译、Rust 桥接与系统框架链接通过。
- iPhone ARM64 主 App 与键盘扩展编译、链接、IPA 打包通过；最低 iOS 16.0。
- 下载的 IPA 为 4,199,579 字节；SHA-256：`7ff15758424c820e20b1914f5e57c237358fcd3bb9704c9a94ab6f6860cc6629`。
- ZIP 完整性、两个 Bundle Identifier 的关系、键盘服务声明、ARM64 iOS 真机可执行文件、可执行权限均已检查。
- 扩展内包含 `dict.qj`（3,538,584 字节）和 `glossary-en.qj`（5,785,264 字节）；从实际 IPA 提取的资源再次通过中文候选与英文释义端到端测试。
- `RequestsOpenAccess` 为 false；包内没有签名或个人 provisioning profile，需要在自己电脑上签名。

## 尚未完成

- 模拟器加载键盘扩展。
- 用当前 iOS 和免费账号签名后安装，键盘在备忘录/微信里的实际表现。
- 真机内存峰值、冷启动速度、布局和连续快速输入测试。

本交付包括已编译的未签名 IPA；尚未经过真机验收，不能据此宣称已成功安装。
