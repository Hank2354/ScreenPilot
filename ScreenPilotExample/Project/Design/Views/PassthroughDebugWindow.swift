import UIKit

final class PassthroughDebugWindow: UIWindow {

    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView === rootViewController?.view ? nil : hitView
    }

    func setup() {
        windowLevel = .alert + 1
        backgroundColor = .clear
        isUserInteractionEnabled = true
    }
}
