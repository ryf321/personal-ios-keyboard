// 键盘的宿主 App，只提供启用指引与试打区，不申请联网或共享容器权限。
import SwiftUI

@main
struct PersonalKeyboardApp: App {
    var body: some Scene {
        WindowGroup { SetupView() }
    }
}
