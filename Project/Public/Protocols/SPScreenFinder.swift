import UIKit.UIViewController
// TODO: Добавить доку
public protocol SPScreenFinder {
    func findScreen(
        matching screen: UIViewController,
        startingFrom topViewController: UIViewController
    ) -> UIViewController?
}
