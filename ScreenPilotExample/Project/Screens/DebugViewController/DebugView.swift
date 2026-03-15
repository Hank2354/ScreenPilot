import UIKit

@MainActor
protocol DebugViewOutput: AnyObject, Sendable {
    func debugButtonTapped()
    func overlayCloseTapped()
    func didSelectedNavigation(_ action: NavigationAction)
}

final class DebugView: UIView {

    weak var output: DebugViewOutput? {
        didSet {
            debugButton.setAction(output?.debugButtonTapped)
        }
    }

    private lazy var overlayView: OverlayView = {
        let overlayView = OverlayView()
        overlayView.prepareForAutoLayout()
        overlayView.onClose = { [weak self] in self?.output?.overlayCloseTapped() }
        overlayView.onNavigationAction = { [weak self] action in self?.output?.didSelectedNavigation(action) }
        return overlayView
    }()
    private lazy var debugButton: Button = {
        let configuration = ButtonCustomConfiguration(
            buttonStyle: .circle,
            highlightAnimationProperties: [.scale]
        )

        let button = Button()

        button.configure(
            title: Constants.debugButtonTitle,
            customConfiguration: configuration
        )
        button.backgroundColor = .systemBlue

        button.prepareForAutoLayout()

        return button
    }()

    private var isOverlayEnabled: Bool = false {
        didSet {
            isOverlayEnabled ? overlayView.show() : overlayView.hide()
        }
    }

    func configure() {
        backgroundColor = .clear
        setupSubviews()
    }

    func toggleOverlay() {
        isOverlayEnabled.toggle()
    }

    func updateHierarchy(_ hierarchy: String) {
        overlayView.updateHierarchy(hierarchy)
    }

    private func setupSubviews() {
        addSubview(overlayView)
        addSubview(debugButton)

        let overlayViewConstraints: [NSLayoutConstraint] = [
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]

        let debugButtonConstraints: [NSLayoutConstraint] = [
            debugButton.widthAnchor.constraint(equalToConstant: Constants.debugButtonSize),
            debugButton.heightAnchor.constraint(equalTo: debugButton.widthAnchor),
            debugButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            debugButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -98)
        ]

        NSLayoutConstraint.activate(overlayViewConstraints + debugButtonConstraints)
    }
}

private extension DebugView {

    @MainActor
    enum Constants {
        static let debugButtonTitle = "Control"
        static let debugButtonSize: CGFloat = 62
    }
}
