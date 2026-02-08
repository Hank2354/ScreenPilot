import UIKit

final class HierarchyDebugView: UIView {
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "View Controller Hierarchy"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let hierarchyTextView: UITextView = {
        let textView = UITextView()
        textView.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        textView.textColor = .label
        textView.backgroundColor = .tertiarySystemBackground
        textView.layer.cornerRadius = 8
        textView.isEditable = false
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Refresh", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Callbacks
    
    var onRefresh: (() -> Void)?
    
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
        containerView.addSubview(refreshButton)
        containerView.addSubview(hierarchyTextView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            refreshButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            refreshButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            hierarchyTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            hierarchyTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            hierarchyTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            hierarchyTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            hierarchyTextView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    // MARK: - Public Methods
    
    func updateHierarchy(_ hierarchy: String) {
        hierarchyTextView.text = hierarchy
    }
    
    // MARK: - Actions
    
    @objc private func refreshButtonTapped() {
        onRefresh?()
    }
}
