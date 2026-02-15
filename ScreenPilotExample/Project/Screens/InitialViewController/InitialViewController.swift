
import UIKit

class InitialViewController: UIViewController {

    private var castedView: InitialView {
        view as! InitialView
    }

    override func loadView() {
        view = InitialView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        castedView.configure()
    }
}
