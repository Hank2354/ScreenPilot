import UIKit

final class DebugPanelView: UIView {
    
    // MARK: - Callbacks
    
    var onClose: (() -> Void)?
    var onNavigationAction: ((NavigationAction) -> Void)?
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let headerView: DebugPanelHeaderView = {
        let view = DebugPanelHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let hierarchyView: HierarchyDebugView = {
        let view = HierarchyDebugView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let openActionsView: OpenActionsDebugView = {
        let view = OpenActionsDebugView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let closeActionsView: CloseActionsDebugView = {
        let view = CloseActionsDebugView()
        view.translatesAutoresizingMaskIntoConstraints = false
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
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        
        addSubview(headerView)
        addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(hierarchyView)
        contentStackView.addArrangedSubview(openActionsView)
        contentStackView.addArrangedSubview(closeActionsView)
        
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Content stack
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 12),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -12),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -24)
        ])
    }
    
    private func setupCallbacks() {
        headerView.onClose = { [weak self] in
            self?.onClose?()
        }
        
        hierarchyView.onRefresh = { [weak self] in
            // Trigger hierarchy update through parent
            if let parent = self?.superview as? OverlayView {
                parent.updateHierarchy()
            }
        }
        
        openActionsView.onAction = { [weak self] action in
            self?.onNavigationAction?(action)
        }
        
        closeActionsView.onAction = { [weak self] action in
            self?.onNavigationAction?(action)
        }
    }
    
    // MARK: - Public Methods
    
    func updateHierarchy(_ hierarchy: String) {
        hierarchyView.updateHierarchy(hierarchy)
    }
}
