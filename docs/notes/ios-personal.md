# 个人 iOS 移植工程

移动端桥接在 `engine/`，UIKit 外壳在 `ios/Keyboard/`。上游四个 vendor crate 未改；排序、解析、消耗拼音与释义仍由 Engine 完成。

Resources 从上游基础 dict.tsv 与对应词条的英文 gloss 筛选，`pack` 写为 .qj；键盘只读 mmap 文件，不加载全量 TSV。候选最多给界面 30 项，拼音缓冲上限 64 ASCII 字符。FFI 的 JSON 返回值由 qj_string_free 释放，句柄只在一个串行队列里用。选择候选带帧版本号，过期点击不提交。

iOS 显示控件使用原生 UIKit，尚未采用上游桌面渲染器。个人测试版通过键盘内译词开关配置，不使用共享 App Group 或完全访问；云端功能与输入持久化未接入。验证边界见根目录 VALIDATION.md。

GitHub 构建先运行 prepare_resources.py，从固定上游 SHA 下载、按 SHA-256 校验数据并筛选英文词表。仅构建阶段联网，手机运行仍离线。main 推送会自动构建。
