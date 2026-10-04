// 候选的显示数据，排序与释义均由核心提供。
import Foundation

struct CandidateViewData: Decodable {
    let text: String
    let gloss: String
}
