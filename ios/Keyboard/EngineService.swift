// 词库加载与查询在同一后台队列上完成，不阻塞键盘主线程。
import Foundation

final class EngineService {
    private let queue = DispatchQueue(label: "personal.keyboard.engine", qos: .userInteractive)
    private var handle: OpaquePointer?

    func start(completion: @escaping (Bool) -> Void) {
        queue.async { [self] in
            if let dict = Bundle.main.path(forResource: "dict", ofType: "qj"),
               let gloss = Bundle.main.path(forResource: "glossary-en", ofType: "qj") {
                handle = dict.withCString { d in gloss.withCString { g in qj_create(d, g) } }
            }
            let ready = handle != nil
            DispatchQueue.main.async { completion(ready) }
        }
    }

    func send(_ action: String, index: Int = 0, revision: UInt64 = 0,
              completion: @escaping (EngineFrame?) -> Void) {
        queue.async { [self] in
            guard let handle else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            let pointer = action.withCString { qj_dispatch(handle, $0, index, revision) }
            var frame: EngineFrame?
            if let pointer {
                let data = Data(String(cString: pointer).utf8)
                qj_string_free(pointer)
                frame = try? JSONDecoder().decode(EngineFrame.self, from: data)
            }
            let result = frame
            DispatchQueue.main.async { completion(result) }
        }
    }

    deinit {
        // 已入队任务持有 self；最后一个任务结束后句柄才会被释放。
        if let handle { qj_destroy(handle) }
    }
}
