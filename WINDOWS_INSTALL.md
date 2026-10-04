# Windows → iPhone：免费编译与安装

## 先弄清两个环节

Windows 不能用 Xcode 本地编译本工程，但可以从免费的云端 macOS runner 下载编译产物，再在 Windows 用自己的 Apple 账号签名。

这份文件是工程的安装流程，不代表已有可用 IPA。当前需要先成功完成一次 macOS 编译和真机验证。源码压缩包不能直接装到 iPhone。

## 第一步：建立自己的 GitHub 仓库

1. 注册或登录免费 GitHub 账号。
2. 创建一个空仓库，例如 `personal-ios-keyboard`。
3. 如果选择公共仓库，源码会公开，标准 GitHub Actions runner 运行时间免费。若选择私有仓库，先确认免费额度足够，并把付费超额预算设为 0；本流程不用付费大规格 runner。
4. 下载并解压源码包。将 **Cargo.toml、engine、vendor、ios、scripts、.github 等内容放在仓库根目录**，不要多套一层文件夹。Windows 资源管理器里 `.github` 是正常目录。
5. 网页上传容易漏掉 `.github` 或大量源码文件，推荐用免费的 GitHub Desktop 发布仓库；确认 Actions 页面能看到 `Build personal iOS keyboard`。

无需上传 Apple 密码、手机号、签名证书或账号信息。

## 第二步：云端编译

1. 打开仓库的 **Actions**。
2. 选择 **Build personal iOS keyboard**。
3. 点击 **Run workflow**。
4. 编译流程会先打包词库、跑核心测试，再用 macOS/Xcode 编译模拟器和 iPhone 版本。
5. 成功后，在运行页面下方 **Artifacts** 下载 `PersonalKeyboard-unsigned-ipa`。
6. 解压下载的产物，得到 `PersonalKeyboard-unsigned.ipa`。

产物仅保留 3 天；本地下载后妥善保留。如果编译失败，保留失败日志继续修复，不能跳过错误宣称能安装。

## 第三步：用 Windows 安装 AltStore Classic

官方指引：<https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows>

1. 按官方指引安装所需的 Apple iTunes/iCloud 组件和 AltServer。选择免费 **AltStore Classic** 路线。
2. iPhone 用数据线连接 Windows，解锁，选择「信任这台电脑」。
3. 从 Windows 任务栏 AltServer 菜单选择 **Install AltStore → 你的 iPhone**。
4. 自己在 AltServer 中登录 Apple 账号；不需要把密码提供给聊天、源码仓库或编译流程。
5. iPhone 设置 → 通用 → VPN 与设备管理，信任自己的开发者身份。
6. 按系统提示开启开发者模式（设置 → 隐私与安全 → 开发者模式，可能需要重启）。

## 第四步：导入自己的 IPA

1. 把 `PersonalKeyboard-unsigned.ipa` 放入 iPhone「文件」App 可访问的位置。
2. 打开 AltStore Classic 的 **My Apps**，使用 `+` 导入这个 IPA。
3. 若提示是否保留 App Extensions，选择 **Keep App Extensions / 保留扩展**。键盘本身是扩展，删掉后只剩主 App，无法输入。
4. 等待签名安装完成。免费账号的 App ID/应用名额有限；本工程是主 App 加 1 个键盘扩展。
5. 如果安装工具或你的当前 iOS 拒绝签名键盘扩展，保留报错继续确认兼容性，不购买企业证书或付费代签。

官方侧载与续签说明：<https://faq.altstore.io/altstore-classic/your-altstore>

## 第五步：启用并试打

1. 打开「随学键盘」主 App。
2. 设置 → 通用 → 键盘 → 键盘 → 添加新键盘 → 随学键盘。
3. 不开启「允许完全访问」。
4. 打开备忘录，长按地球键选「随学键盘」。
5. 试打 `nihao`（你好）、`kaifa`（开发）、`gongzuo`（工作），检查候选及英文释义。
6. 试打 `kaifazhe`，选「开发」，确认剩余 `zhe` 还在候选栏；随后退格，确认没有误删正文。
7. 验证微信/搜索框、横竖屏和系统深色模式。密码框、部分电话号码框或禁止第三方键盘的 App 会自动使用系统键盘，这是 iOS 的限制。

## 以后每周

免费个人签名通常 7 天到期。保持 AltServer 可访问，并在 AltStore 里 **Refresh All** 续签；能自动续签时仍要检查状态。过期就需要重新签名安装，不能保证 0 元永久免维护。

Apple 官方限制：<https://developer.apple.com/help/account/basics/about-your-developer-account>
GitHub 免费标准 runner 说明：<https://docs.github.com/en/billing/concepts/product-billing/github-actions>
