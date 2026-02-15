import UIKit

final class LabeledSwitch: UIView {
    
    var isOn: Bool {
        get { switchControl.isOn }
        set { switchControl.isOn = newValue }
    }
    
    var onValueChanged: ((Bool) -> Void)?
    
    private let label: UILabel = {
        let label = UILabel()
        label.prepareForAutoLayout()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.prepareForAutoLayout()
        return switchControl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override var intrinsicContentSize: CGSize {
        let labelSize = label.intrinsicContentSize
        let switchSize = switchControl.intrinsicContentSize
        return CGSize(
            width: labelSize.width + 8 + switchSize.width,
            height: max(labelSize.height, switchSize.height)
        )
    }
    
    func configure(
        text: String,
        isOn: Bool = true,
        font: UIFont? = nil
    ) {
        label.text = text
        switchControl.isOn = isOn
        
        if let font = font {
            label.font = font
        }
    }
    
    private func setupUI() {
        addSubview(label)
        addSubview(switchControl)
        
        let labelConstraints: [NSLayoutConstraint] = [
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        
        let switchConstraints: [NSLayoutConstraint] = [
            switchControl.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            switchControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            switchControl.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(labelConstraints + switchConstraints)
    }
    
    private func setupActions() {
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        onValueChanged?(sender.isOn)
    }
}
