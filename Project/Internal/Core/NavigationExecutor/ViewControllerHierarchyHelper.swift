import UIKit.UIViewController

protocol ViewControllerHierarchyHelper {
    func findModalRoot(for viewController: UIViewController) -> UIViewController?
    func findTopViewController(from viewController: UIViewController) -> UIViewController?
    func countScreens(in viewController: UIViewController) -> Int
}

class ViewControllerHierarchyHelperImpl: ViewControllerHierarchyHelper {
    
    func findModalRoot(for viewController: UIViewController) -> UIViewController? {
        var current: UIViewController = viewController
        
        if let navController = current.navigationController {
            current = navController
        }
        
        if current.presentingViewController != nil {
            return current
        }
        
        return nil
    }
    
    func findTopViewController(from viewController: UIViewController) -> UIViewController? {
        var current = viewController
        
        while let presented = current.presentedViewController {
            current = presented
        }
        
        if let navController = current as? UINavigationController {
            return navController.topViewController
        }
        
        if let tabController = current as? UITabBarController,
           let selected = tabController.selectedViewController {
            if let navController = selected as? UINavigationController {
                return navController.topViewController
            }
            return selected
        }
        
        return current
    }
    
    func countScreens(in viewController: UIViewController) -> Int {
        if let navController = viewController as? UINavigationController {
            return navController.viewControllers.count
        }
        
        if let navController = viewController.navigationController,
           let index = navController.viewControllers.firstIndex(of: viewController) {
            return index + 1
        }
        
        return 1
    }
}
