import UIKit

final class OpenActionsDebugView: UIView {
    
    // MARK: - Callbacks
    
    var onAction: ((NavigationAction) -> Void)?
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Open Screen Actions"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let animationSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = true
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    private let animationLabel: UILabel = {
        let label = UILabel()
        label.text = "Animated"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Push settings
    private let pushCountStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.maximumValue = 5
        stepper.value = 1
        stepper.translatesAutoresizingMaskIntoConstraints = false
        return stepper
    }()
    
    private let pushCountLabel: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Modal settings
    private let modalCountStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.maximumValue = 5
        stepper.value = 1
        stepper.translatesAutoresizingMaskIntoConstraints = false
        return stepper
    }()
    
    private let modalCountLabel: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let modalNavSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = true
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    private let modalNavLabel: UILabel = {
        let label = UILabel()
        label.text = "With Nav"
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupSteppers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(animationLabel)
        containerView.addSubview(animationSwitch)
        containerView.addSubview(buttonsStackView)
        
        setupButtons()
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            animationSwitch.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            animationSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            animationLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            animationLabel.trailingAnchor.constraint(equalTo: animationSwitch.leadingAnchor, constant: -8),
            
            buttonsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            buttonsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            buttonsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            buttonsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupButtons() {
        // Push row
        let pushRow = createPushRow()
        buttonsStackView.addArrangedSubview(pushRow)
        
        // Modal row
        let modalRow = createModalRow()
        buttonsStackView.addArrangedSubview(modalRow)
    }
    
    private func createPushRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let pushButton = UIButton(type: .system)
        pushButton.setTitle("Push", for: .normal)
        pushButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        pushButton.backgroundColor = .systemBlue
        pushButton.setTitleColor(.white, for: .normal)
        pushButton.layer.cornerRadius = 6
        pushButton.translatesAutoresizingMaskIntoConstraints = false
        pushButton.addAction(UIAction { [weak self] _ in
            self?.handlePushAction()
        }, for: .touchUpInside)
        
        container.addSubview(pushButton)
        container.addSubview(pushCountLabel)
        container.addSubview(pushCountStepper)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 36),
            
            pushButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            pushButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            pushButton.widthAnchor.constraint(equalToConstant: 70),
            pushButton.heightAnchor.constraint(equalToConstant: 36),
            
            pushCountLabel.leadingAnchor.constraint(equalTo: pushButton.trailingAnchor, constant: 8),
            pushCountLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            pushCountLabel.widthAnchor.constraint(equalToConstant: 25),
            
            pushCountStepper.leadingAnchor.constraint(equalTo: pushCountLabel.trailingAnchor, constant: 4),
            pushCountStepper.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            pushCountStepper.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor)
        ])
        
        return container
    }
    
    private func createModalRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let modalButton = UIButton(type: .system)
        modalButton.setTitle("Modal", for: .normal)
        modalButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        modalButton.backgroundColor = .systemBlue
        modalButton.setTitleColor(.white, for: .normal)
        modalButton.layer.cornerRadius = 6
        modalButton.translatesAutoresizingMaskIntoConstraints = false
        modalButton.addAction(UIAction { [weak self] _ in
            self?.handleModalAction()
        }, for: .touchUpInside)
        
        let settingsStack = UIStackView()
        settingsStack.axis = .horizontal
        settingsStack.spacing = 4
        settingsStack.alignment = .center
        settingsStack.translatesAutoresizingMaskIntoConstraints = false
        
        settingsStack.addArrangedSubview(modalCountLabel)
        settingsStack.addArrangedSubview(modalCountStepper)
        settingsStack.addArrangedSubview(modalNavLabel)
        settingsStack.addArrangedSubview(modalNavSwitch)
        
        container.addSubview(modalButton)
        container.addSubview(settingsStack)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 36),
            
            modalButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            modalButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            modalButton.widthAnchor.constraint(equalToConstant: 70),
            modalButton.heightAnchor.constraint(equalToConstant: 36),
            
            settingsStack.leadingAnchor.constraint(equalTo: modalButton.trailingAnchor, constant: 8),
            settingsStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            settingsStack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
            
            modalCountLabel.widthAnchor.constraint(equalToConstant: 25)
        ])
        
        return container
    }
    
    private func setupSteppers() {
        pushCountStepper.addTarget(self, action: #selector(pushCountChanged), for: .valueChanged)
        modalCountStepper.addTarget(self, action: #selector(modalCountChanged), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    @objc private func pushCountChanged() {
        pushCountLabel.text = "\(Int(pushCountStepper.value))"
    }
    
    @objc private func modalCountChanged() {
        modalCountLabel.text = "\(Int(modalCountStepper.value))"
    }
    
    private func handlePushAction() {
        let count = Int(pushCountStepper.value)
        let animated = animationSwitch.isOn
        onAction?(.push(count: count, animated: animated))
    }
    
    private func handleModalAction() {
        let count = Int(modalCountStepper.value)
        let withNav = modalNavSwitch.isOn
        let animated = animationSwitch.isOn
        onAction?(.modal(count: count, withNavigation: withNav, animated: animated))
    }
}
