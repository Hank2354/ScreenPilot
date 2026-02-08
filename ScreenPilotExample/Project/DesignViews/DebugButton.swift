import UIKit

final class DebugButton: UIButton {
    typealias TapAction = () -> Void

    private var tapAction: TapAction?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        self.addTarget(self, action: #selector(_onTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(bounds.height, bounds.width) / 2
    }

    override var isHighlighted: Bool {
        didSet {
            updateHighlightedState(isHighlighted)
        }
    }
}

// MARK: - Interface
extension DebugButton {

    func onTap(_ tapAction: @escaping TapAction) {
        self.tapAction = tapAction
    }
}

// MARK: - Private
private extension DebugButton {

    func setupUI() {
        backgroundColor = .systemBlue
        setTitle("Control", for: .normal)
    }

    @objc func _onTap() {
        tapAction?()
    }

    func updateHighlightedState(_ isHighlighted: Bool) {
        UIView.animate(withDuration: 0.07) {
            self.alpha = self.isHighlighted ? 0.7 : 1
            self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
        }
    }
}
