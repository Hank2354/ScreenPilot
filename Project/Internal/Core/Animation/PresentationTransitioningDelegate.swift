import UIKit.UIViewControllerTransitioning

class PresentationTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    private let presentAnimator: UIViewControllerAnimatedTransitioning?
    private let dismissAnimator: UIViewControllerAnimatedTransitioning?
    
    init(
        presentAnimator: UIViewControllerAnimatedTransitioning?,
        dismissAnimator: UIViewControllerAnimatedTransitioning?
    ) {
        self.presentAnimator = presentAnimator
        self.dismissAnimator = dismissAnimator
        super.init()
    }
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        presentAnimator
    }
    
    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        dismissAnimator
    }
}
