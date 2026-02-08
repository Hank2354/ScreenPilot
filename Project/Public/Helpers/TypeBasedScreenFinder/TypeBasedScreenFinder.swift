import UIKit
// TODO: Порефачить, добавить доку и поставить префикс SP
public class TypeBasedScreenFinder: SPScreenFinder {

    public init() {}
    
    public func findScreen(
        matching screen: UIViewController,
        startingFrom topViewController: UIViewController
    ) -> UIViewController? {
        let targetType = type(of: screen)
        let hierarchy = buildHierarchy(from: topViewController)
        
        for vc in hierarchy {
            guard type(of: vc) == targetType else { continue }
            
            if let comparableVC = vc as? SPScreenContextComparable,
               let comparableScreen = screen as? SPScreenContextComparable {
                if comparableVC.contextHash == comparableScreen.contextHash {
                    return vc
                }
            } else {
                return vc
            }
        }
        
        return nil
    }
}

private extension TypeBasedScreenFinder {

    private func buildHierarchy(from topViewController: UIViewController) -> [UIViewController] {
        var hierarchy: [UIViewController] = []
        var current: UIViewController? = topViewController

        while let vc = current {
            hierarchy.append(vc)

            if let navController = vc.navigationController {
                let viewControllers = navController.viewControllers
                if let index = viewControllers.firstIndex(of: vc), index > 0 {
                    for i in stride(from: index - 1, through: 0, by: -1) {
                        hierarchy.append(viewControllers[i])
                    }
                }
                current = findPresentingViewController(for: navController)
            } else if let presenting = vc.presentingViewController {
                current = findTopViewController(from: presenting)
            } else {
                current = nil
            }
        }

        return hierarchy
    }

    private func findPresentingViewController(for viewController: UIViewController) -> UIViewController? {
        guard let presenting = viewController.presentingViewController else {
            return nil
        }
        return findTopViewController(from: presenting)
    }

    private func findTopViewController(from viewController: UIViewController) -> UIViewController? {
        let current = viewController

        if let navController = current as? UINavigationController,
           let top = navController.topViewController {
            return top
        }

        if let tabController = current as? UITabBarController,
           let selected = tabController.selectedViewController {
            return findTopViewController(from: selected)
        }

        return current
    }
}
