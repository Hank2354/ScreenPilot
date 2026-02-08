import UIKit

@MainActor
class CloseToOperationFactory {
    
    private let hierarchyHelper: ViewControllerHierarchyHelper
    
    init(hierarchyHelper: ViewControllerHierarchyHelper) {
        self.hierarchyHelper = hierarchyHelper
    }
    
    func makeOperations(
        from currentViewController: UIViewController,
        to targetViewController: UIViewController,
        animation: SPNavigationAnimation
    ) -> [NavigationOperation]? {
        let path = buildPath(from: currentViewController, to: targetViewController)
        
        guard !path.isEmpty else {
            return nil
        }
        
        return path.map { $0.toOperation(animation: animation) }
    }
}

private extension CloseToOperationFactory {
    
    enum PathStep {
        case popTo(navigationController: UINavigationController, targetVC: UIViewController)
        case popToRoot(navigationController: UINavigationController)
        case dismiss(viewController: UIViewController)
        
        func toOperation(animation: SPNavigationAnimation) -> NavigationOperation {
            switch self {
            case .popTo(let navController, let targetVC):
                let context = NavigationOperation.PopToContext(
                    targetViewController: targetVC,
                    navigationController: navController,
                    animation: animation
                )
                return .popTo(context)
                
            case .popToRoot(let navController):
                let context = NavigationOperation.PopToRootContext(
                    navigationController: navController,
                    animation: animation
                )
                return .popToRoot(context)
                
            case .dismiss(let viewController):
                let context = NavigationOperation.DismissContext(
                    viewController: viewController,
                    count: 1,
                    animation: animation,
                    sequential: false
                )
                return .dismiss(context)
            }
        }
    }

    func buildPath(
        from current: UIViewController,
        to target: UIViewController
    ) -> [PathStep] {
        var path: [PathStep] = []
        var currentVC: UIViewController? = current

        while let vc = currentVC {
            if vc === target {
                return path
            }

            if let step = tryPopToTarget(from: vc, to: target, path: &path) {
                path.append(step)
                return path
            }
            
            if let step = tryPopToRootAndContinue(from: vc, next: &currentVC) {
                path.append(step)
                continue
            }
            
            if let step = tryDismissModal(from: vc, next: &currentVC) {
                path.append(step)
                continue
            }
            
            break
        }

        return []
    }
    
    func tryPopToTarget(
        from viewController: UIViewController,
        to target: UIViewController,
        path: inout [PathStep]
    ) -> PathStep? {
        guard let navController = viewController.navigationController,
              let targetIndex = navController.viewControllers.firstIndex(where: { $0 === target }),
              let currentIndex = navController.viewControllers.firstIndex(of: viewController),
              currentIndex > targetIndex else {
            return nil
        }
        
        return .popTo(navigationController: navController, targetVC: target)
    }
    
    func tryPopToRootAndContinue(
        from viewController: UIViewController,
        next: inout UIViewController?
    ) -> PathStep? {
        guard let navController = viewController.navigationController else {
            return nil
        }
        
        let currentIndex = navController.viewControllers.firstIndex(of: viewController) ?? 0
        
        next = hierarchyHelper.findModalRoot(for: navController)?.presentingViewController
        
        guard currentIndex > 0 else {
            return nil
        }
        
        return .popToRoot(navigationController: navController)
    }
    
    func tryDismissModal(
        from viewController: UIViewController,
        next: inout UIViewController?
    ) -> PathStep? {
        guard let modalRoot = hierarchyHelper.findModalRoot(for: viewController) else {
            return nil
        }
        
        next = modalRoot.presentingViewController
        
        return .dismiss(viewController: modalRoot)
    }
}
