import UIKit

final class InitialView: UIView {

    private lazy var titleMessageLabel: UILabel = {
        let label = UILabel()
        label.prepareForAutoLayout()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.prepareForAutoLayout()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: .screenPilotLogo)
        imageView.prepareForAutoLayout()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    func configure() {
        backgroundColor = .systemBackground
        setupSubviews()
    }

    private func setupSubviews() {
        addSubview(logoImageView)
        addSubview(titleMessageLabel)
        addSubview(infoLabel)

        let logoImageViewConstraints: [NSLayoutConstraint] = [
            logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 32),
            logoImageView.heightAnchor.constraint(equalToConstant: 128),
            logoImageView.widthAnchor.constraint(equalTo: logoImageView.heightAnchor)
        ]

        let titleMessageLabelConstraints: [NSLayoutConstraint] = [
            titleMessageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleMessageLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 32),
            titleMessageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleMessageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ]

        let infoLabelConstraints: [NSLayoutConstraint] = [
            infoLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -52),
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 70),
        ]

        NSLayoutConstraint.activate(logoImageViewConstraints + titleMessageLabelConstraints + infoLabelConstraints)

        titleMessageLabel.text = Constants.titleMessage
        infoLabel.text = Constants.infoMessage
    }
}

private extension InitialView {

    @MainActor
    enum Constants {
        static let titleMessage = "A library for easily building app navigation"
        static let infoMessage = "<- Tap this button\n       to open debug panel"
    }
}
