import UIKit

final class LabeledStepper: UIView {
    
    var value: Int {
        get { Int(stepper.value) }
        set { 
            stepper.value = Double(newValue)
            updateLabel()
        }
    }
    
    var onValueChanged: ((Int) -> Void)?
    
    private let label: UILabel = {
        let label = UILabel()
        label.prepareForAutoLayout()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private lazy var stepper: UIStepper = {
        let stepper = UIStepper()
        stepper.prepareForAutoLayout()
        return stepper
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
        let labelSize = CGSize(width: 25, height: label.intrinsicContentSize.height)
        let stepperSize = stepper.intrinsicContentSize
        return CGSize(
            width: labelSize.width + 4 + stepperSize.width,
            height: max(labelSize.height, stepperSize.height)
        )
    }
    
    func configure(
        value: Int = 1,
        minimumValue: Int = 1,
        maximumValue: Int = 5
    ) {
        stepper.minimumValue = Double(minimumValue)
        stepper.maximumValue = Double(maximumValue)
        stepper.value = Double(value)
        updateLabel()
    }
    
    private func setupUI() {
        addSubview(label)
        addSubview(stepper)
        
        let labelConstraints: [NSLayoutConstraint] = [
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.widthAnchor.constraint(equalToConstant: 25)
        ]
        
        let stepperConstraints: [NSLayoutConstraint] = [
            stepper.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 4),
            stepper.trailingAnchor.constraint(equalTo: trailingAnchor),
            stepper.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(labelConstraints + stepperConstraints)
    }
    
    private func setupActions() {
        stepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
    }
    
    @objc private func stepperValueChanged(_ sender: UIStepper) {
        updateLabel()
        onValueChanged?(Int(sender.value))
    }
    
    private func updateLabel() {
        label.text = "\(Int(stepper.value))"
    }
}
