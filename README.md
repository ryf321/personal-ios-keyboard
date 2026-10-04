# 随学键盘：基于青简核心的 iPhone 个人测试工程

这是按「只给自己用、尽量 0 元」制作的离线 iOS 移植工程。它不是青简官方 iOS 发行版，也还不是已经在 iPhone 上验证过的成品。

## 目前已有

- 青简原始 Rust 引擎与 C ABI 桥接；26 键拼音、中文候选、英文释义。
- 横向滚动候选、中英文切换、数字/符号、空格/回车/退格、地球键。
- 主 App 的键盘启用说明和试打区。
- 91,919 个不同中文词条，88,112 条英文释义；`.qj` 内存映射资源。
- macOS 编译脚本、XcodeGen 工程配置、GitHub Actions 未签名 IPA 编译流程。
- 不申请完全访问，不联网、不保存输入日志、不使用收费 API。

第一版没有九宫格、语音、滑行输入、云联想、App 与键盘共享设置、个人词频持久化或桌面版神经语言模型。释义随上游数据，机器生成内容可能不准确。

## 当前验证范围

查看 `VALIDATION.md`。Rust 核心、FFI 和随包资源测试已通过；云端 macOS/Xcode 的 ARM64 模拟器与 iPhone 版本均已编译、链接成功，并生成约 4 MiB 的未签名 IPA。已检查包内主 App、键盘扩展、离线词库和 iPhone ARM64 可执行文件。系统键盘启用、免费签名与实际内存占用仍需在自己的 iPhone 上验证。

成功编译记录：<https://github.com/ryf321/personal-ios-keyboard/actions/runs/37204153245>。`ios/Libraries/` 中的静态库在构建时生成，不纳入 Git。

**源码 ZIP 不能直接安装到 iPhone。未签名的 IPA 也需要自己的 Apple 账号签名。不要把它误认为已完成安装。**

## 只有 Windows 的 0 元路线

完整步骤见 `WINDOWS_INSTALL.md`。

仓库构建时从固定上游 commit 下载词库、校验 SHA-256 并筛选释义；键盘使用时完全离线。

1. 用免费 GitHub 账号建立自己的仓库，把源码上传。
2. 运行随附的 GitHub Actions，用云端 macOS/Xcode 编译。
3. 成功后下载 `PersonalKeyboard-unsigned.ipa`。
4. Windows 上安装免费 AltServer/AltStore Classic，使用自己的 Apple 账号签名并安装。
5. iPhone 设置里添加「随学键盘」。免费签名每 7 天需要续签。

GitHub 公共仓库使用标准 runner 的运行时间免费，但源码将公开；私有仓库只能在账号自带的免费额度内运行，不能保证账号已有的额度没有被其他项目用完。本工程不会上传密码、证书或付款信息，也不会自动创建或公开你的仓库。

## 有 Mac 的路线

安装免费 Xcode、Rust、XcodeGen 后，在工程根目录运行：

```bash
bash scripts/build.sh device
```

这会生成 `ios/PersonalKeyboard.xcodeproj` 与未签名 IPA。在 Xcode 打开工程，两个 target 均选择自己的 Personal Team，连接 iPhone，必要时修改 Bundle Identifier 后运行。免费个人签名无需购买开发者年费。

模拟器编译：

```bash
bash scripts/build.sh simulator
```

只构建 Rust 与验证数据（Linux/Windows/macOS 都可运行）：

```bash
python3 scripts/prepare_resources.py
cargo run --locked -p qingjian-ios --bin pack -- ios/Resources
cargo test --locked -p qingjian-ios
cargo clippy --locked -p qingjian-ios --all-targets -- -D warnings
```

## 来源与许可

上游：<https://github.com/qingjian-team/qingjian>，固定 commit 见 `UPSTREAM.txt`。`vendor/` 的四个核心 crate 保持原样。代码为 GPL-3.0-or-later，完整许可在 `LICENSE`；词库来源与署名在 `licenses/`。本移植采用「随学键盘」名称，不使用官方 Logo。这里附带完整移植源码，方便个人修改及后续修复。
