import UIKit

final class HighlightingGestureRecognizer: UIGestureRecognizer {
    typealias GestureHandler = (_ gestureRecognizer: UIGestureRecognizer) -> Void

    private let handler: GestureHandler?

    required init(handler: ((_ gestureRecognizer: UIGestureRecognizer) -> Void)?) {
        self.handler = handler
        super.init(target: nil, action: nil)

        addTarget(self, action: #selector(handleHighlighting(_:)))
    }

    public override func canPrevent(_: UIGestureRecognizer) -> Bool {
        return false
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        state = .began
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)

        guard let view = view, let point = Array(touches).last?.location(in: view) else {
            return
        }

        if view.bounds.contains(point) {
            state = .changed
        } else {
            state = .cancelled
        }
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        state = .ended
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        state = .cancelled
    }

    @objc private func handleHighlighting(_ gestureRecognizer: UIGestureRecognizer) {
        handler?(gestureRecognizer)
    }
}
