import UIKit

enum NavigationOperation {
    case push(PushContext)
    case pop(PopContext)
    case popToRoot(PopToRootContext)
    case popTo(PopToContext)
    case setViewControllers(SetViewControllersContext)
    case replaceTop(ReplaceTopContext)
    case present(PresentContext)
    case dismiss(DismissContext)
    case dismissAll(DismissAllContext)
    case close(CloseContext)
    case closeTo(CloseToContext)

    struct PushContext {
        let viewControllers: [UIViewController]
        let navigationController: UINavigationController
        let animation: SPNavigationAnimation
    }
    
    struct PopContext {
        let navigationController: UINavigationController
        let count: Int
        let animation: SPNavigationAnimation
    }
    
    struct PopToRootContext {
        let navigationController: UINavigationController
        let animation: SPNavigationAnimation
    }
    
    struct PopToContext {
        let targetViewController: UIViewController
        let navigationController: UINavigationController
        let animation: SPNavigationAnimation
    }
    
    struct SetViewControllersContext {
        let viewControllers: [UIViewController]
        let navigationController: UINavigationController
        let animation: SPNavigationAnimation
    }
    
    struct PresentContext {
        let viewControllers: [UIViewController]
        let presenter: UIViewController
        let presentationStyle: UIModalPresentationStyle
        let animation: SPNavigationAnimation
    }
    
    struct DismissContext {
        let viewController: UIViewController
        let count: Int
        let animation: SPNavigationAnimation
        let sequential: Bool
    }
    
    struct CloseContext {
        let fromViewController: UIViewController
        let count: Int
        let animation: SPNavigationAnimation
    }
    
    struct ReplaceTopContext {
        let viewController: UIViewController
        let navigationController: UINavigationController
        let animation: SPNavigationAnimation
    }
    
    struct DismissAllContext {
        let fromViewController: UIViewController
        let animation: SPNavigationAnimation
    }
    
    struct CloseToContext {
        let fromViewController: UIViewController
        let targetViewController: UIViewController
        let animation: SPNavigationAnimation
    }
}
