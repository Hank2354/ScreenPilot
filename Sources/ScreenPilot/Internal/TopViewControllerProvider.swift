import UIKit

@MainActor
protocol TopViewControllerProvider {
    var topViewController: UIViewController? { get }
}

class TopViewControllerProviderImpl: TopViewControllerProvider {
    
    private let rootViewControllerProvider: SPRootViewControllerProvider

    init(rootViewControllerProvider: SPRootViewControllerProvider) {
        self.rootViewControllerProvider = rootViewControllerProvider
    }

    var topViewController: UIViewController? {
        guard let rootViewController = rootViewControllerProvider.rootViewController else {
            return nil
        }

        return getTopViewController(from: rootViewController)
    }
}

private extension TopViewControllerProviderImpl {
    
    func getTopViewController(from viewController: UIViewController) -> UIViewController {
        if let presented = viewController.presentedViewController {
            return getTopViewController(from: presented)
        }
        
        if let child = viewController.children.last {
            return getTopViewController(from: child)
        }

        if let navigationController = viewController as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return getTopViewController(from: visibleViewController)
        }

        if let tabBarController = viewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return getTopViewController(from: selectedViewController)
        }

        return viewController
    }
}
