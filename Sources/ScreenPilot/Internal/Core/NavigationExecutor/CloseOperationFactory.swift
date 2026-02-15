import UIKit

@MainActor
class CloseOperationFactory {
    
    private let hierarchyHelper: ViewControllerHierarchyHelper
    
    init(hierarchyHelper: ViewControllerHierarchyHelper) {
        self.hierarchyHelper = hierarchyHelper
    }

    func makeOperations(
        from viewController: UIViewController,
        count: Int,
        animation: SPNavigationAnimation
    ) -> [NavigationOperation] {
        var operations: [NavigationOperation] = []
        var remaining = count
        var current: UIViewController? = viewController

        while remaining > 0, let currentVC = current {
            if let dismissOperation = tryDismissModal(
                from: currentVC,
                remaining: &remaining,
                current: &current,
                animation: animation
            ) {
                operations.append(dismissOperation)
                continue
            }
            
            if let popOperation = tryPopNavigation(
                from: currentVC,
                remaining: &remaining,
                current: &current,
                animation: animation
            ) {
                operations.append(popOperation)
                continue
            }
            
            break
        }

        return operations
    }
}

private extension CloseOperationFactory {
    
    func tryDismissModal(
        from viewController: UIViewController,
        remaining: inout Int,
        current: inout UIViewController?,
        animation: SPNavigationAnimation
    ) -> NavigationOperation? {
        guard let modalRoot = hierarchyHelper.findModalRoot(for: viewController),
              let presentingVC = modalRoot.presentingViewController else {
            return nil
        }
        
        let screensInModal = hierarchyHelper.countScreens(in: modalRoot)
        
        guard remaining >= screensInModal else {
            return nil
        }
        
        remaining -= screensInModal
        
        if remaining > 0 {
            current = hierarchyHelper.resolveContentViewController(from: presentingVC)
        } else {
            current = nil
        }

        let context = NavigationOperation.DismissContext(
            viewController: modalRoot,
            count: 1,
            animation: animation,
            sequential: false
        )

        return .dismiss(context)
    }
    
    func tryPopNavigation(
        from viewController: UIViewController,
        remaining: inout Int,
        current: inout UIViewController?,
        animation: SPNavigationAnimation
    ) -> NavigationOperation? {
        guard let navController = viewController.navigationController else {
            return nil
        }
        
        let currentIndex = navController.viewControllers.firstIndex(of: viewController)
            ?? (navController.viewControllers.count - 1)
        
        guard currentIndex > 0 else {
            return nil
        }
        
        let popCount = min(remaining, currentIndex)
        remaining -= popCount
        
        if remaining > 0 {
            let targetIndex = currentIndex - popCount
            current = navController.viewControllers[targetIndex]
        } else {
            current = nil
        }

        let context = NavigationOperation.PopContext(
            navigationController: navController,
            count: popCount,
            animation: animation
        )

        return .pop(context)
    }
}
