import UIKit.UIViewController

/**
 Root ViewController provider in host application

 - parameter rootViewController: Root ViewController (by UIWindow.rootViewControllet or concrete SDK viewController)
 */
public class SPRootViewControllerProvider {

    public weak var rootViewController: UIViewController?

    public init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
}
