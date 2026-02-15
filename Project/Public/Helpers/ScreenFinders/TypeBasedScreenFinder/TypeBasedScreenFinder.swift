import UIKit.UIViewController

/**
 Default implementation of `SPScreenFinder` that matches screens by type and optional context.

 ## Overview
 `SPDefaultScreenFinder` searches through the navigation hierarchy to find existing view controllers.
 It matches screens using two criteria:
 1. **Type matching**: Compares view controller types using `type(of:)`
 2. **Context matching**: If screens conform to `SPScreenContextComparable`, also compares their `contextHash`

 The search traverses the entire hierarchy including navigation stacks, modals, and tab bars,
 starting from the top view controller and working backwards through presenting view controllers.

 # Example #
 ```swift
 let finder = SPDefaultScreenFinder()
 
 let config = SPNavigationConfiguration(
     screenFinder: finder,
     animation: .default
 )
 
 // If a matching screen exists, navigate to it instead of creating a new one
 await navigator.navigate(
     to: [profileScreen],
     style: .push,
     configuration: config
 )
 ```
 */
public final class SPDefaultScreenFinder: SPScreenFinder {

    public init() {}
    
    public func findScreen(
        matching screen: UIViewController,
        startingFrom topViewController: UIViewController
    ) -> UIViewController? {
        let targetType = type(of: screen)
        let hierarchy = buildHierarchy(from: topViewController)
        
        return findMatchingViewController(
            in: hierarchy,
            targetType: targetType,
            targetScreen: screen
        )
    }
}

// MARK: - Screen Matching

private extension SPDefaultScreenFinder {
    
    func findMatchingViewController(
        in hierarchy: [UIViewController],
        targetType: UIViewController.Type,
        targetScreen: UIViewController
    ) -> UIViewController? {
        for viewController in hierarchy {
            guard type(of: viewController) == targetType else {
                continue
            }
            
            if shouldMatchByContext(viewController, with: targetScreen) {
                if contextsMatch(viewController, with: targetScreen) {
                    return viewController
                }
            } else {
                // Type matches and no context comparison needed
                return viewController
            }
        }
        
        return nil
    }
    
    func shouldMatchByContext(
        _ viewController: UIViewController,
        with targetScreen: UIViewController
    ) -> Bool {
        return viewController is SPScreenContextComparable 
            && targetScreen is SPScreenContextComparable
    }
    
    func contextsMatch(
        _ viewController: UIViewController,
        with targetScreen: UIViewController
    ) -> Bool {
        guard let comparableVC = viewController as? SPScreenContextComparable,
              let comparableScreen = targetScreen as? SPScreenContextComparable else {
            return false
        }
        
        return comparableVC.contextHash == comparableScreen.contextHash
    }
}

// MARK: - Hierarchy Building

private extension SPDefaultScreenFinder {

    func buildHierarchy(from topViewController: UIViewController) -> [UIViewController] {
        var hierarchy: [UIViewController] = []
        var currentViewController: UIViewController? = topViewController

        while let viewController = currentViewController {
            hierarchy.append(viewController)
            currentViewController = findNextViewController(from: viewController)
        }

        return hierarchy
    }
    
    func findNextViewController(from viewController: UIViewController) -> UIViewController? {
        // If inside a navigation controller, add all view controllers from the stack
        if let navigationController = viewController.navigationController {
            addNavigationStackToHierarchy(
                navigationController: navigationController,
                currentViewController: viewController,
                hierarchy: &[]
            )
            return findPresentingViewController(for: navigationController)
        }
        
        // Otherwise, traverse up the presentation chain
        if let presentingViewController = viewController.presentingViewController {
            return resolveTopViewController(from: presentingViewController)
        }
        
        return nil
    }
    
    func addNavigationStackToHierarchy(
        navigationController: UINavigationController,
        currentViewController: UIViewController,
        hierarchy: inout [UIViewController]
    ) {
        let viewControllers = navigationController.viewControllers
        
        guard let currentIndex = viewControllers.firstIndex(of: currentViewController),
              currentIndex > 0 else {
            return
        }
        
        // Add all view controllers before the current one in reverse order
        for index in stride(from: currentIndex - 1, through: 0, by: -1) {
            hierarchy.append(viewControllers[index])
        }
    }

    func findPresentingViewController(
        for viewController: UIViewController
    ) -> UIViewController? {
        guard let presentingViewController = viewController.presentingViewController else {
            return nil
        }
        return resolveTopViewController(from: presentingViewController)
    }

    func resolveTopViewController(
        from viewController: UIViewController
    ) -> UIViewController? {
        // Unwrap navigation controller
        if let navigationController = viewController as? UINavigationController {
            return navigationController.topViewController
        }

        // Unwrap tab bar controller recursively
        if let tabBarController = viewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return resolveTopViewController(from: selectedViewController)
        }

        return viewController
    }
}
