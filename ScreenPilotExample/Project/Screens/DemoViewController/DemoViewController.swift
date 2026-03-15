import UIKit

final class DemoViewController: UIViewController {

    let screenNumber: Int

    private var navigationManager: NavigationManager
    private let color: UIColor

    private var castedView: DemoView {
        view as! DemoView
    }

    init(
        navigationManager: NavigationManager,
        color: UIColor,
        screenNumber: Int
    ) {
        self.navigationManager = navigationManager
        self.color = color
        self.screenNumber = screenNumber

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    override func loadView() {
        view = DemoView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        castedView.output = self
        castedView.configure(screenNumber: screenNumber, color: color)
    }
}

extension DemoViewController: DemoViewOutput {

    func didTapPushButton() {
        Task {
            let navigationAction = NavigationAction.push(count: 1, animated: true)
            await navigationManager.execute(navigationAction)
        }
    }
    
    func didTapModalButton() {
        Task {
            let navigationAction = NavigationAction.modal(count: 1, withNavigation: true, animated: true)
            await navigationManager.execute(navigationAction)
        }
    }
}
