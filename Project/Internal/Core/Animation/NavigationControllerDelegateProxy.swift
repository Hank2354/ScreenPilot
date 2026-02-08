import UIKit.UINavigationController
import UIKit.UIViewControllerTransitioning

class NavigationControllerDelegateProxy: NSObject, UINavigationControllerDelegate {
    
    private weak var originalDelegate: UINavigationControllerDelegate?
    private var pushAnimator: UIViewControllerAnimatedTransitioning?
    private var popAnimator: UIViewControllerAnimatedTransitioning?
    
    init(
        originalDelegate: UINavigationControllerDelegate?,
        pushAnimator: UIViewControllerAnimatedTransitioning?,
        popAnimator: UIViewControllerAnimatedTransitioning?
    ) {
        self.originalDelegate = originalDelegate
        self.pushAnimator = pushAnimator
        self.popAnimator = popAnimator
        super.init()
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            if let animator = pushAnimator {
                return animator
            }
        case .pop:
            if let animator = popAnimator {
                return animator
            }
        case .none:
            break
        @unknown default:
            break
        }
        
        return originalDelegate?.navigationController?(
            navigationController,
            animationControllerFor: operation,
            from: fromVC,
            to: toVC
        )
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        originalDelegate?.navigationController?(
            navigationController,
            willShow: viewController,
            animated: animated
        )
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        originalDelegate?.navigationController?(
            navigationController,
            didShow: viewController,
            animated: animated
        )
    }
    
    func navigationControllerSupportedInterfaceOrientations(
        _ navigationController: UINavigationController
    ) -> UIInterfaceOrientationMask {
        originalDelegate?
            .navigationControllerSupportedInterfaceOrientations?(navigationController) ?? .all
    }
    
    func navigationControllerPreferredInterfaceOrientationForPresentation(
        _ navigationController: UINavigationController
    ) -> UIInterfaceOrientation {
        originalDelegate?
            .navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController) ?? .portrait
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        originalDelegate?.navigationController?(
            navigationController,
            interactionControllerFor: animationController
        )
    }
}
