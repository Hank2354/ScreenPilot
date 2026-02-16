import UIKit

final class OverlayView: UIView {
    
    var onClose: (() -> Void)?
    var onNavigationAction: ((NavigationAction) -> Void)?
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.prepareForAutoLayout()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    private let debugPanelView: DebugPanelView = {
        let view = DebugPanelView()
        view.prepareForAutoLayout()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupCallbacks()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func show() {
        isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
    }
    
    func updateHierarchy(_ hierarchy: String) {
        debugPanelView.updateHierarchy(hierarchy)
    }
}

private extension OverlayView {
    
    func setupUI() {
        alpha = 0
        isHidden = true
        
        addSubview(backgroundView)
        addSubview(debugPanelView)

        let backgroundViewConstraints: [NSLayoutConstraint] = [
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]

        let debugPanelConstraints: [NSLayoutConstraint] = [
            debugPanelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            debugPanelView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            debugPanelView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            debugPanelView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ]

        NSLayoutConstraint.activate(backgroundViewConstraints + debugPanelConstraints)
    }
    
    func setupCallbacks() {
        debugPanelView.onClose = { [weak self] in
            self?.onClose?()
        }
        
        debugPanelView.onNavigationAction = { [weak self] action in
            self?.onNavigationAction?(action)
        }
    }
}
