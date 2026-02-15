import UIKit

final class HierarchyDebugView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.prepareForAutoLayout()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.prepareForAutoLayout()
        label.text = "View Controller Hierarchy"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let hierarchyTextView: UITextView = {
        let textView = UITextView()
        textView.prepareForAutoLayout()
        textView.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        textView.textColor = .label
        textView.backgroundColor = .tertiarySystemBackground
        textView.layer.cornerRadius = 8
        textView.isEditable = false
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return textView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupUI() {
        addSubview(containerView)

        containerView.addSubview(titleLabel)
        containerView.addSubview(hierarchyTextView)
        
        let containerViewConstraints: [NSLayoutConstraint] = [
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        let titleLabelConstraints: [NSLayoutConstraint] = [
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16)
        ]
        
        let hierarchyTextViewConstraints: [NSLayoutConstraint] = [
            hierarchyTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            hierarchyTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            hierarchyTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            hierarchyTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            hierarchyTextView.heightAnchor.constraint(equalToConstant: 150)
        ]
        
        NSLayoutConstraint.activate(
            containerViewConstraints +
            titleLabelConstraints +
            hierarchyTextViewConstraints
        )
    }
    
    func updateHierarchy(_ hierarchy: String) {
        hierarchyTextView.text = hierarchy
    }
}
