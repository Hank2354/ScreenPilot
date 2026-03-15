import UIKit

@MainActor
protocol DemoViewOutput: AnyObject {
    func didTapPushButton()
    func didTapModalButton()
}

final class DemoView: UIView {

    weak var output: DemoViewOutput?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.prepareForAutoLayout()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.prepareForAutoLayout()
        label.text = "This is a demo screen"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private lazy var pushButton: UIButton = {
        let button = UIButton(type: .system)
        button.prepareForAutoLayout()
        button.setTitle("Push New Screen", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .white.withAlphaComponent(0.3)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(pushButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var modalButton: UIButton = {
        let button = UIButton(type: .system)
        button.prepareForAutoLayout()
        button.setTitle("Open Modal", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .white.withAlphaComponent(0.3)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(modalButtonTapped), for: .touchUpInside)
        return button
    }()

    func configure(screenNumber: Int, color: UIColor) {
        titleLabel.text = "Screen \(screenNumber)"
        setupUI(color: color)
    }

    private func setupUI(color: UIColor) {
        backgroundColor = color

        addSubview(titleLabel)
        addSubview(infoLabel)
        addSubview(pushButton)
        addSubview(modalButton)

        let titleLabelConstraints: [NSLayoutConstraint] = [
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -80)
        ]

        let infoLabelConstraints: [NSLayoutConstraint] = [
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            infoLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ]

        let pushButtonConstraints: [NSLayoutConstraint] = [
            pushButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 40),
            pushButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            pushButton.widthAnchor.constraint(equalToConstant: 200),
            pushButton.heightAnchor.constraint(equalToConstant: 50)
        ]

        let modalButtonConstraints: [NSLayoutConstraint] = [
            modalButton.topAnchor.constraint(equalTo: pushButton.bottomAnchor, constant: 16),
            modalButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            modalButton.widthAnchor.constraint(equalToConstant: 200),
            modalButton.heightAnchor.constraint(equalToConstant: 50)
        ]

        NSLayoutConstraint.activate(
            titleLabelConstraints +
            infoLabelConstraints +
            pushButtonConstraints +
            modalButtonConstraints
        )
    }

    @objc private func pushButtonTapped() {
        output?.didTapPushButton()
    }

    @objc private func modalButtonTapped() {
        output?.didTapModalButton()
    }
}
