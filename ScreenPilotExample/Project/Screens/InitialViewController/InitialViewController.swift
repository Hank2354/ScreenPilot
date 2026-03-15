
import UIKit

class InitialViewController: UIViewController {

    private let tabIndex: Int

    init(tabIndex: Int) {
        self.tabIndex = tabIndex
        super.init(nibName: nil, bundle: nil)

        tabBarItem = UITabBarItem(
            title: "Screen \(tabIndex)",
            image: .checkmark,
            tag: tabIndex
        )

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var castedView: InitialView {
        view as! InitialView
    }

    override func loadView() {
        view = InitialView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        castedView.configure(screenNumber: tabIndex)
    }
}
