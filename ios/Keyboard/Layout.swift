// 固定候选区域与四行按键；窄屏与横屏都由 Auto Layout 分配宽度。
import UIKit

extension KeyboardViewController {
    func buildLayout() {
        view.backgroundColor = .systemGroupedBackground
        showGloss = UserDefaults.standard.object(forKey: "showGloss") as? Bool ?? true
        rootStack.axis = .vertical
        rootStack.spacing = 6
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rootStack)
        keyboardHeight = view.heightAnchor.constraint(equalToConstant: 310)
        keyboardHeight?.priority = .defaultHigh
        keyboardHeight?.isActive = true
        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            rootStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
            rootStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4)
        ])
        preeditLabel.font = .systemFont(ofSize: 13)
        preeditLabel.textColor = .secondaryLabel
        preeditLabel.text = "正在加载离线词库…"
        rootStack.addArrangedSubview(preeditLabel)
        preeditLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        candidateScroll.showsHorizontalScrollIndicator = false
        candidateScroll.heightAnchor.constraint(equalToConstant: 58).isActive = true
        rootStack.addArrangedSubview(candidateScroll)
        candidateStack.axis = .horizontal
        candidateStack.spacing = 8
        candidateStack.translatesAutoresizingMaskIntoConstraints = false
        candidateScroll.addSubview(candidateStack)
        NSLayoutConstraint.activate([
            candidateStack.leadingAnchor.constraint(equalTo: candidateScroll.contentLayoutGuide.leadingAnchor),
            candidateStack.trailingAnchor.constraint(equalTo: candidateScroll.contentLayoutGuide.trailingAnchor),
            candidateStack.topAnchor.constraint(equalTo: candidateScroll.contentLayoutGuide.topAnchor),
            candidateStack.bottomAnchor.constraint(equalTo: candidateScroll.contentLayoutGuide.bottomAnchor),
            candidateStack.heightAnchor.constraint(equalTo: candidateScroll.frameLayoutGuide.heightAnchor)
        ])
        keyStack.axis = .vertical
        keyStack.distribution = .fillEqually
        keyStack.spacing = 7
        rootStack.addArrangedSubview(keyStack)
    }

    func buildKeys() {
        keyStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        var rows: [[String]]
        if symbolPage == 1 {
            rows = [Array("1234567890").map(String.init), Array("-/:;()¥&@\"").map(String.init),
                    ["#+=", ".", ",", "?", "!", "'", "⌫"]]
        } else if symbolPage == 2 {
            rows = [Array("[]{}#%^*+=").map(String.init), Array("_\\|~<>€£$•").map(String.init),
                    ["123", "。", "，", "？", "！", "…", "⌫"]]
        } else {
            rows = [Array("qwertyuiop").map(String.init), Array("asdfghjkl").map(String.init),
                    ["⇧"] + Array("zxcvbnm").map(String.init) + ["⌫"]]
        }
        rows.append([symbolPage == 0 ? "123" : "ABC", "🌐", "中/英", "空格", "译", "回车"])
        for (rowIndex, keys) in rows.enumerated() {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 5
            row.distribution = rowIndex == 3 ? .fill : .fillEqually
            for key in keys {
                let title = shifted && englishMode && key.count == 1 ? key.uppercased() : key
                let button = KeyButton(title, special: key.count > 1 || ["🌐", "⇧", "⌫", "译"].contains(key))
                if key == "🌐" {
                    button.isHidden = !needsInputModeSwitchKey
                    button.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
                } else {
                    button.addAction(UIAction { [weak self] _ in self?.handle(title) }, for: .touchUpInside)
                }
                row.addArrangedSubview(button)
                if rowIndex == 3 {
                    if key != "空格" {
                        let width = button.widthAnchor.constraint(equalTo: row.widthAnchor, multiplier: 0.12)
                        width.priority = UILayoutPriority(999)
                        width.isActive = true
                    }
                }
            }
            keyStack.addArrangedSubview(row)
            if rowIndex == 1 && symbolPage == 0 {
                row.isLayoutMarginsRelativeArrangement = true
                row.layoutMargins = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
            }
        }
    }

    func render(_ frame: EngineFrame) {
        preeditLabel.text = frame.preedit.isEmpty ? (englishMode ? "英文" : "中文 · 英文释义") : frame.preedit
        if let error = frame.error { preeditLabel.text = error }
        candidateStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, candidate) in frame.candidates.enumerated() {
            let button = UIButton(type: .system)
            var config = UIButton.Configuration.plain()
            config.title = candidate.text
            config.subtitle = showGloss ? candidate.gloss : nil
            config.baseForegroundColor = .label
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
                var result = attributes
                result.font = .systemFont(ofSize: 21)
                return result
            }
            config.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
                var result = attributes
                result.font = .systemFont(ofSize: 12)
                result.foregroundColor = UIColor.secondaryLabel
                return result
            }
            button.configuration = config
            button.accessibilityLabel = candidate.text + " " + candidate.gloss
            button.addAction(UIAction { [weak self] _ in
                self?.send("select", index: index, revision: frame.revision)
            }, for: .touchUpInside)
            candidateStack.addArrangedSubview(button)
        }
        candidateScroll.setContentOffset(.zero, animated: false)
    }
}
