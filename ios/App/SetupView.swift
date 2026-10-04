// 用户指引；译词开关在键盘内，避免免费签名对 App Group 的限制。
import SwiftUI

struct SetupView: View {
    @State private var sample = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("随手打字，顺便看英语")
                        .font(.title3.bold())
                    Text("中文拼音输入 · 本地英文释义")
                        .foregroundColor(.secondary)
                }
                Section("启用键盘") {
                    Text("1. 打开 iPhone 设置")
                    Text("2. 通用 → 键盘 → 键盘 → 添加新键盘")
                    Text("3. 选择「随学键盘」")
                    Text("4. 回到输入框，长按地球键切换")
                    Text("无需开启「允许完全访问」。")
                        .foregroundColor(.secondary)
                }
                Section("试一试") {
                    TextField("试打 kaifa、nihao、gongzuo", text: $sample)
                    Text("点候选输入中文；空格选首项；回车提交拼音；「译」显示或隐藏英文释义。")
                        .font(.footnote).foregroundColor(.secondary)
                }
                Section("关于") {
                    Text("个人测试版 0.1.0 · 基于青简开源核心")
                    Text("第一版全部离线，不保存输入记录。英文释义来自上游机器生成词表，可能有不准确之处。")
                    Text("免费签名有效期通常为 7 天，到期前请在电脑上续签。")
                }
            }
            .navigationTitle("随学键盘")
        }
    }
}
