// 原生按键控件，保留辅助功能标签和系统按压反馈。
import UIKit

final class KeyButton: UIButton {
    init(_ title: String, special: Bool = false) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.label, for: .normal)
        titleLabel?.font = .systemFont(ofSize: special ? 15 : 23)
        titleLabel?.adjustsFontSizeToFitWidth = true
        backgroundColor = special ? .systemGray3 : .secondarySystemGroupedBackground
        layer.cornerRadius = 6
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 0
        accessibilityLabel = title
        heightAnchor.constraint(greaterThanOrEqualToConstant: 32).isActive = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is unsupported") }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.55 : 1 }
    }
}
