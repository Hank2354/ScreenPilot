import UIKit

final class DebugPanelHeaderView: UIView {
    
    var onClose: (() -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.prepareForAutoLayout()
        label.text = "ScreenPilot Debug Panel"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private lazy var closeButton: Button = {
        let button = Button()
        button.prepareForAutoLayout()
        button.configure(
            title: "✕",
            titleColor: .black,
            action: { [weak self] in
                self?.onClose?()
            }
        )
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .medium)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupUI() {
        backgroundColor = .systemBlue
        
        addSubview(titleLabel)
        addSubview(closeButton)
        
        let titleLabelConstraints: [NSLayoutConstraint] = [
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
        ]
        
        let closeButtonConstraints: [NSLayoutConstraint] = [
            closeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ]
        
        NSLayoutConstraint.activate(titleLabelConstraints + closeButtonConstraints)
    }
}
