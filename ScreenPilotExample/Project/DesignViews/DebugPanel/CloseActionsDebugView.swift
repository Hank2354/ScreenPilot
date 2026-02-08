import UIKit

final class CloseActionsDebugView: UIView {
    
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
        label.text = "Close Screen Actions"
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
    
    // Pop settings
    private let popCountStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.maximumValue = 5
        stepper.value = 1
        stepper.translatesAutoresizingMaskIntoConstraints = false
        return stepper
    }()
    
    private let popCountLabel: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Dismiss settings
    private let dismissCountStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.maximumValue = 5
        stepper.value = 1
        stepper.translatesAutoresizingMaskIntoConstraints = false
        return stepper
    }()
    
    private let dismissCountLabel: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Close settings
    private let closeCountStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.maximumValue = 5
        stepper.value = 1
        stepper.translatesAutoresizingMaskIntoConstraints = false
        return stepper
    }()
    
    private let closeCountLabel: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
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
        // Pop row
        buttonsStackView.addArrangedSubview(createPopRow())
        
        // Pop to Root row
        buttonsStackView.addArrangedSubview(createSimpleButtonRow(title: "Pop to Root", action: { [weak self] in
            self?.handlePopToRootAction()
        }))
        
        // Dismiss row
        buttonsStackView.addArrangedSubview(createDismissRow())
        
        // Dismiss All row
        buttonsStackView.addArrangedSubview(createSimpleButtonRow(title: "Dismiss All", action: { [weak self] in
            self?.handleDismissAllAction()
        }))
        
        // Close row
        buttonsStackView.addArrangedSubview(createCloseRow())
    }
    
    private func createPopRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(type: .system)
        button.setTitle("Pop", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            self?.handlePopAction()
        }, for: .touchUpInside)
        
        container.addSubview(button)
        container.addSubview(popCountLabel)
        container.addSubview(popCountStepper)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 36),
            
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 36),
            
            popCountLabel.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 8),
            popCountLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            popCountLabel.widthAnchor.constraint(equalToConstant: 25),
            
            popCountStepper.leadingAnchor.constraint(equalTo: popCountLabel.trailingAnchor, constant: 4),
            popCountStepper.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            popCountStepper.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor)
        ])
        
        return container
    }
    
    private func createDismissRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(type: .system)
        button.setTitle("Dismiss", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            self?.handleDismissAction()
        }, for: .touchUpInside)
        
        container.addSubview(button)
        container.addSubview(dismissCountLabel)
        container.addSubview(dismissCountStepper)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 36),
            
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 36),
            
            dismissCountLabel.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 8),
            dismissCountLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            dismissCountLabel.widthAnchor.constraint(equalToConstant: 25),
            
            dismissCountStepper.leadingAnchor.constraint(equalTo: dismissCountLabel.trailingAnchor, constant: 4),
            dismissCountStepper.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            dismissCountStepper.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor)
        ])
        
        return container
    }
    
    private func createCloseRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            self?.handleCloseAction()
        }, for: .touchUpInside)
        
        container.addSubview(button)
        container.addSubview(closeCountLabel)
        container.addSubview(closeCountStepper)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 36),
            
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 36),
            
            closeCountLabel.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 8),
            closeCountLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            closeCountLabel.widthAnchor.constraint(equalToConstant: 25),
            
            closeCountStepper.leadingAnchor.constraint(equalTo: closeCountLabel.trailingAnchor, constant: 4),
            closeCountStepper.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            closeCountStepper.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor)
        ])
        
        return container
    }
    
    private func createSimpleButtonRow(title: String, action: @escaping () -> Void) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        
        container.addSubview(button)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 36),
            
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            button.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        return container
    }
    
    private func setupSteppers() {
        popCountStepper.addTarget(self, action: #selector(popCountChanged), for: .valueChanged)
        dismissCountStepper.addTarget(self, action: #selector(dismissCountChanged), for: .valueChanged)
        closeCountStepper.addTarget(self, action: #selector(closeCountChanged), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    @objc private func popCountChanged() {
        popCountLabel.text = "\(Int(popCountStepper.value))"
    }
    
    @objc private func dismissCountChanged() {
        dismissCountLabel.text = "\(Int(dismissCountStepper.value))"
    }
    
    @objc private func closeCountChanged() {
        closeCountLabel.text = "\(Int(closeCountStepper.value))"
    }
    
    private func handlePopAction() {
        let count = Int(popCountStepper.value)
        let animated = animationSwitch.isOn
        onAction?(.pop(count: count, animated: animated))
    }
    
    private func handlePopToRootAction() {
        let animated = animationSwitch.isOn
        onAction?(.popToRoot(animated: animated))
    }
    
    private func handleDismissAction() {
        let count = Int(dismissCountStepper.value)
        let animated = animationSwitch.isOn
        onAction?(.dismiss(count: count, animated: animated))
    }
    
    private func handleDismissAllAction() {
        let animated = animationSwitch.isOn
        onAction?(.dismissAll(animated: animated))
    }
    
    private func handleCloseAction() {
        let count = Int(closeCountStepper.value)
        let animated = animationSwitch.isOn
        onAction?(.close(count: count, animated: animated))
    }
}
