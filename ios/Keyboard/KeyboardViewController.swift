// 只把触摸事件交给核心，拼音不提前插入宿主，防止取消组句时误删正文。
import UIKit

final class KeyboardViewController: UIInputViewController {
    let engine = EngineService()
    let rootStack = UIStackView()
    let keyStack = UIStackView()
    let candidateStack = UIStackView()
    let candidateScroll = UIScrollView()
    let preeditLabel = UILabel()
    var latest: EngineFrame?
    var englishMode = false
    var shifted = false
    var symbolPage = 0
    var showGloss = true
    var ready = false
    var epoch = 0
    var editingHost = false
    var keyboardHeight: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        buildKeys()
        engine.start { [weak self] success in
            guard let self else { return }
            self.ready = success
            self.preeditLabel.text = success ? "中文 · 英文释义" : "词库加载失败，可切换英文"
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let landscape = view.bounds.width > 600
        keyboardHeight?.constant = landscape ? 260 : 310
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        epoch += 1
        latest = nil
        engine.send("clear") { _ in }
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        guard !editingHost else { return }
        // 焦点或宿主光标发生变化时丢弃未提交组句，不跨输入框保留拼音。
        epoch += 1
        latest = nil
        candidateStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        engine.send("clear") { _ in }
        preeditLabel.text = englishMode ? "英文" : "中文 · 英文释义"
    }

    func send(_ action: String, index: Int = 0, revision: UInt64 = 0,
              then: (() -> Void)? = nil) {
        let requestedEpoch = epoch
        engine.send(action, index: index, revision: revision) { [weak self] frame in
            guard let self, requestedEpoch == self.epoch else { return }
            guard let frame else {
                self.preeditLabel.text = "引擎暂不可用，请切换键盘"
                return
            }
            if !frame.committed.isEmpty { self.insertHost(frame.committed) }
            if frame.delete_backward { self.deleteHost() }
            self.latest = frame
            self.render(frame)
            then?()
        }
    }

    func insertHost(_ text: String) {
        editingHost = true
        textDocumentProxy.insertText(text)
        editingHost = false
    }

    func deleteHost() {
        editingHost = true
        textDocumentProxy.deleteBackward()
        editingHost = false
    }

    func handle(_ key: String) {
        switch key {
        case "🌐": advanceToNextInputMode()
        case "中/英":
            epoch += 1
            engine.send("clear") { _ in }
            latest = nil
            englishMode.toggle()
            symbolPage = 0
            preeditLabel.text = englishMode ? "英文" : "中文 · 英文释义"
            candidateStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            buildKeys()
        case "译":
            showGloss.toggle()
            UserDefaults.standard.set(showGloss, forKey: "showGloss")
            if let latest { render(latest) }
        case "⇧": shifted.toggle(); buildKeys()
        case "123": symbolPage = 1; buildKeys()
        case "#+=": symbolPage = 2; buildKeys()
        case "ABC": symbolPage = 0; buildKeys()
        case "⌫":
            if !englishMode && ready {
                send("backspace")
            } else { deleteHost() }
        case "空格":
            if !englishMode && ready {
                send("first") { [weak self] in
                    guard let self else { return }
                    if self.latest?.committed.isEmpty == true { self.insertHost(" ") }
                }
            } else { insertHost(" ") }
        case "回车":
            if !englishMode && ready {
                send("raw") { [weak self] in
                    guard let self else { return }
                    if self.latest?.committed.isEmpty == true { self.insertHost("\n") }
                }
            } else { insertHost("\n") }
        default:
            if symbolPage == 0 && !englishMode && ready {
                send(key.lowercased())
            } else if !englishMode && ready {
                send("raw") { [weak self] in self?.insertHost(key) }
            } else { insertHost(key) }
            if shifted { shifted = false; buildKeys() }
        }
    }
}
