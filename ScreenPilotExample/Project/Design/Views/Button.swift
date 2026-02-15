import UIKit

struct ButtonCustomConfiguration {
    let buttonStyle: ButtonStyle
    let highlightAnimationProperties: [HighlightAnimationProperties]

    enum HighlightAnimationProperties: CaseIterable {
        case scale
        case alpha
    }

    enum ButtonStyle {
        case circle
        case square
        case roundedSquare(ratio: CGFloat)
    }

    static let `default` = Self(
        buttonStyle: .roundedSquare(
            ratio: 4
        ),
        highlightAnimationProperties: [
            .alpha,
            .scale
        ]
    )
}

final class Button: UIButton {
    typealias ButtonAction = @MainActor @Sendable () -> Void

    private var action: ButtonAction?
    private var customConfiguration: ButtonCustomConfiguration = .default
    private var scaleAnimator: UIViewPropertyAnimator?

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        setupUI()
        addTarget(self, action: #selector(handleAction), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let cornerRadius = switch customConfiguration.buttonStyle {
            case .circle:
                min(bounds.height, bounds.width) / 2
            case .square:
                CGFloat(0)
            case .roundedSquare(let ratio):
                min(bounds.height, bounds.width) / ratio
        }

        layer.cornerRadius = cornerRadius
    }

    func configure(
        title: String,
        backgroundColor: UIColor? = nil,
        titleColor: UIColor? = nil,
        customConfiguration: ButtonCustomConfiguration = .default,
        action: ButtonAction? = nil
    ) {
        setTitle(title, for: .normal)
        
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
        
        if let titleColor = titleColor {
            setTitleColor(titleColor, for: .normal)
        }
        
        self.customConfiguration = customConfiguration
        setAction(action)
        setupHighlightingGesture()
    }

    func setAction(_ action: ButtonAction?) {
        self.action = action
    }

    private func setupUI() {
        titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
    }

    private func setupHighlightingGesture() {
        let highlightGestureRecognizer = HighlightingGestureRecognizer { [weak self] gesture in
            guard let self else { return }

            self.scaleAnimator?.stopAnimation(true)

            switch gesture.state {
                case .began:
                    let animator = UIViewPropertyAnimator(
                        duration: Constants.scaleAnimationDuration,
                        timingParameters: Constants.pressTiming
                    )

                    for property in customConfiguration.highlightAnimationProperties {
                        switch property {
                            case .scale:
                                animator.addAnimations {
                                    self.transform = CGAffineTransform(
                                        scaleX: Constants.pressedScale,
                                        y: Constants.pressedScale
                                    )
                                }
                            case .alpha:
                                animator.addAnimations {
                                    self.alpha = Constants.highlightedAlpha
                                }
                        }
                    }

                    self.scaleAnimator = animator

                    animator.startAnimation()
                case .ended, .cancelled, .failed:
                    let animator = UIViewPropertyAnimator(
                        duration: Constants.scaleAnimationDuration,
                        timingParameters: Constants.releaseTiming
                    )

                    for property in customConfiguration.highlightAnimationProperties {
                        switch property {
                            case .scale:
                                animator.addAnimations {
                                    self.transform = .identity
                                }
                            case .alpha:
                                animator.addAnimations {
                                    self.alpha = Constants.initialAlpha
                                }
                        }
                    }

                    self.scaleAnimator = animator

                    animator.startAnimation()
                case .changed, .possible:
                    break
                @unknown default:
                    break
            }
        }

        highlightGestureRecognizer.cancelsTouchesInView = false

        addGestureRecognizer(highlightGestureRecognizer)
    }

    @objc private func handleAction() {
        action?()
    }
}

private extension Button {

    @MainActor
    private enum Constants {
        static let pressedScale: CGFloat = 0.95
        static let scaleAnimationDuration: TimeInterval = 0.1
        static let initialAlpha: CGFloat = 1
        static let highlightedAlpha: CGFloat = 0.7
        static let pressTiming = UICubicTimingParameters(
            controlPoint1: CGPoint(x: 0.32, y: 0),
            controlPoint2: CGPoint(x: 0.67, y: 0)
        )
        static let releaseTiming = UICubicTimingParameters(
            controlPoint1: CGPoint(x: 0.33, y: 1),
            controlPoint2: CGPoint(x: 0.68, y: 1)
        )
    }
}
