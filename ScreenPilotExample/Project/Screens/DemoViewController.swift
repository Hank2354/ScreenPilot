import UIKit

class DemoViewController: UIViewController {
    
    let screenNumber: Int
    private let color: UIColor
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Screen #\(screenNumber)"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.text = "This is a demo screen"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var pushButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Push New Screen", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .white.withAlphaComponent(0.3)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(pushButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var modalButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open Modal", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .white.withAlphaComponent(0.3)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(modalButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(screenNumber: Int, color: UIColor) {
        self.screenNumber = screenNumber
        self.color = color
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Screen \(screenNumber)"
        view.backgroundColor = color
        
        view.addSubview(titleLabel)
        view.addSubview(infoLabel)
        view.addSubview(pushButton)
        view.addSubview(modalButton)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            pushButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 40),
            pushButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pushButton.widthAnchor.constraint(equalToConstant: 200),
            pushButton.heightAnchor.constraint(equalToConstant: 50),
            
            modalButton.topAnchor.constraint(equalTo: pushButton.bottomAnchor, constant: 16),
            modalButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modalButton.widthAnchor.constraint(equalToConstant: 200),
            modalButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func pushButtonTapped() {
        let nextNumber = screenNumber + 1
        let nextScreen = DemoScreenFactory.createScreen(number: nextNumber)
        navigationController?.pushViewController(nextScreen, animated: true)
    }
    
    @objc private func modalButtonTapped() {
        let nextNumber = screenNumber + 1
        let nextScreen = DemoScreenFactory.createScreen(number: nextNumber)
        let navController = UINavigationController(rootViewController: nextScreen)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
}
