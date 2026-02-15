import UIKit

struct ActionRowConfiguration {
    let title: String
    let buttonWidth: CGFloat
    let backgroundColor: UIColor
    let stepper: LabeledStepper?
    let additionalControls: [UIView]
    let action: @Sendable @MainActor () -> Void

    init(
        title: String,
        buttonWidth: CGFloat = 70,
        backgroundColor: UIColor = .systemBlue,
        stepper: LabeledStepper? = nil,
        additionalControls: [UIView] = [],
        action: @escaping @Sendable @MainActor () -> Void
    ) {
        self.title = title
        self.buttonWidth = buttonWidth
        self.backgroundColor = backgroundColor
        self.stepper = stepper
        self.additionalControls = additionalControls
        self.action = action
    }
}

final class OpenActionsDebugView: UIView {
    
    var onAction: ((NavigationAction) -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.prepareForAutoLayout()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.prepareForAutoLayout()
        label.text = "Open Screen Actions"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let animationSwitch: LabeledSwitch = {
        let labeledSwitch = LabeledSwitch()
        labeledSwitch.prepareForAutoLayout()
        labeledSwitch.configure(text: "Animated", isOn: true)
        return labeledSwitch
    }()
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.prepareForAutoLayout()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private let pushCountStepper: LabeledStepper = {
        let stepper = LabeledStepper()
        stepper.prepareForAutoLayout()
        stepper.configure(value: 1, minimumValue: 1, maximumValue: 5)
        return stepper
    }()
    
    private let modalCountStepper: LabeledStepper = {
        let stepper = LabeledStepper()
        stepper.prepareForAutoLayout()
        stepper.configure(value: 1, minimumValue: 1, maximumValue: 5)
        return stepper
    }()
    
    private let modalNavSwitch: LabeledSwitch = {
        let labeledSwitch = LabeledSwitch()
        labeledSwitch.prepareForAutoLayout()
        labeledSwitch.configure(
            text: "With Nav",
            isOn: true,
            font: .systemFont(ofSize: 12, weight: .regular)
        )
        return labeledSwitch
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(animationSwitch)
        containerView.addSubview(buttonsStackView)
        
        setupButtons()
        
        let containerViewConstraints: [NSLayoutConstraint] = [
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        let titleLabelConstraints: [NSLayoutConstraint] = [
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16)
        ]
        
        let animationSwitchConstraints: [NSLayoutConstraint] = [
            animationSwitch.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            animationSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ]
        
        let buttonsStackViewConstraints: [NSLayoutConstraint] = [
            buttonsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            buttonsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            buttonsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            buttonsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ]
        
        NSLayoutConstraint.activate(
            containerViewConstraints +
            titleLabelConstraints +
            animationSwitchConstraints +
            buttonsStackViewConstraints
        )
    }
    
    private func setupButtons() {
        let actions: [ActionRowConfiguration] = [
            ActionRowConfiguration(
                title: "Push",
                stepper: pushCountStepper,
                action: { [weak self] in self?.handlePushAction() }
            ),
            ActionRowConfiguration(
                title: "Modal",
                stepper: modalCountStepper,
                additionalControls: [modalNavSwitch],
                action: { [weak self] in self?.handleModalAction() }
            )
        ]
        
        for config in actions {
            let row = createActionRow(config: config)
            buttonsStackView.addArrangedSubview(row)
        }
    }
    
    private func createActionRow(config: ActionRowConfiguration) -> UIView {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 8
        rowStack.alignment = .center
        
        let button = Button()
        button.configure(
            title: config.title,
            backgroundColor: config.backgroundColor,
            titleColor: .white,
            action: config.action
        )
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 6
        
        let buttonConstraints: [NSLayoutConstraint] = [
            button.widthAnchor.constraint(equalToConstant: config.buttonWidth),
            button.heightAnchor.constraint(equalToConstant: 36)
        ]
        
        NSLayoutConstraint.activate(buttonConstraints)
        
        rowStack.addArrangedSubview(button)
        
        if let stepper = config.stepper {
            rowStack.addArrangedSubview(stepper)
        }
        
        if !config.additionalControls.isEmpty {
            let settingsStack = UIStackView()
            settingsStack.axis = .horizontal
            settingsStack.spacing = 4
            settingsStack.alignment = .center
            
            for control in config.additionalControls {
                settingsStack.addArrangedSubview(control)
            }
            
            rowStack.addArrangedSubview(settingsStack)
        }
        
        return rowStack
    }

    
    private func handlePushAction() {
        let count = pushCountStepper.value
        let animated = animationSwitch.isOn
        onAction?(.push(count: count, animated: animated))
    }
    
    private func handleModalAction() {
        let count = modalCountStepper.value
        let withNav = modalNavSwitch.isOn
        let animated = animationSwitch.isOn
        onAction?(.modal(count: count, withNavigation: withNav, animated: animated))
    }
}
