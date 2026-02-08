import UIKit

final class OverlayView: UIView {
    
    // MARK: - Callbacks
    
    var onClose: (() -> Void)?
    var onNavigationAction: ((NavigationAction) -> Void)?
    var onRefreshHierarchy: (() -> String)?
    
    // MARK: - Properties
    
    private var hierarchyUpdateTimer: Timer?
    
    // MARK: - UI Components
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let debugPanelView: DebugPanelView = {
        let view = DebugPanelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupCallbacks()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func show() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
        updateHierarchy()
        startHierarchyUpdates()
    }
    
    func hide() {
        stopHierarchyUpdates()
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        }
    }
    
    func updateHierarchy() {
        if let hierarchy = onRefreshHierarchy?() {
            debugPanelView.updateHierarchy(hierarchy)
        }
    }
    
    // MARK: - Timer Management
    
    private func startHierarchyUpdates() {
        stopHierarchyUpdates()
        hierarchyUpdateTimer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.updateHierarchy()
            }
        }
    }
    
    private func stopHierarchyUpdates() {
        hierarchyUpdateTimer?.invalidate()
        hierarchyUpdateTimer = nil
    }
}

// MARK: - Private
private extension OverlayView {
    
    func setupUI() {
        alpha = 0
        
        addSubview(backgroundView)
        addSubview(debugPanelView)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            debugPanelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            debugPanelView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            debugPanelView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            debugPanelView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
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
