// Rust 返回的单帧，提交文本在主线程交给宿主输入框。
import Foundation

struct EngineFrame: Decodable {
    let revision: UInt64
    let preedit: String
    let candidates: [CandidateViewData]
    let committed: String
    let delete_backward: Bool
    let error: String?
}
