import UIKit

typealias NavigationOperationItem = Result<[NavigationOperation], SPNavigationError>

@MainActor
class NavigationOperationFactory {
    
    private let topViewControllerProvider: TopViewControllerProvider
    
    init(topViewControllerProvider: TopViewControllerProvider) {
        self.topViewControllerProvider = topViewControllerProvider
    }
    
    func makePushOperation(
        viewControllers: [UIViewController],
        animation: SPNavigationAnimation
    ) -> NavigationOperationItem {
        guard let navigationController = topNavigationController else {
            return .failure(.navigationControllerNotFound)
        }

        let pushContext = NavigationOperation.PushContext(
            viewControllers: viewControllers,
            navigationController: navigationController,
            animation: animation
        )

        let operation = NavigationOperation.push(pushContext)

        return .success([operation])
    }
    
    func makePresentOperation(
        viewControllers: [UIViewController],
        style: UIModalPresentationStyle,
        animation: SPNavigationAnimation
    ) -> NavigationOperationItem {
        guard let presenter = topViewControllerProvider.topViewController else {
            return .failure(.presenterNotFound)
        }

        let presentContext = NavigationOperation.PresentContext(
            viewControllers: viewControllers,
            presenter: presenter,
            presentationStyle: style,
            animation: animation
        )

        let operation = NavigationOperation.present(presentContext)

        return .success([operation])
    }
    
    func makePopOperation(
        count: Int,
        animation: SPNavigationAnimation
    ) -> NavigationOperationItem {
        guard let navigationController = topNavigationController else {
            return .failure(.navigationControllerNotFound)
        }

        let popContext = NavigationOperation.PopContext(
            navigationController: navigationController,
            count: count,
            animation: animation
        )

        let operation = NavigationOperation.pop(popContext)

        return .success([operation])
    }
    
    func makePopToOperation(
        viewController: UIViewController,
        animation: SPNavigationAnimation
    ) -> NavigationOperationItem {
        guard let navigationController = topNavigationController else {
            return .failure(.navigationControllerNotFound)
        }

        let popToContext = NavigationOperation.PopToContext(
            targetViewController: viewController,
            navigationController: navigationController,
            animation: animation
        )

        let operation = NavigationOperation.popTo(popToContext)

        return .success([operation])
    }
    
    func makePopToRootOperation(
        animation: SPNavigationAnimation
    ) -> NavigationOperationItem {
        guard let navigationController = topNavigationController else {
            return .failure(.navigationControllerNotFound)
        }

        let popToRootContext = NavigationOperation.PopToRootContext(
            navigationController: navigationController,
            animation: animation
        )

        let operation = NavigationOperation.popToRoot(popToRootContext)

        return .success([operation])
    }
    
    func makeDismissOperation(
        count: Int,
        animation: SPNavigationAnimation
    ) -> NavigationOperationItem {
        guard let topViewController = topViewControllerProvider.topViewController else {
            return .failure(.presenterNotFound)
        }

        let dismissContext = NavigationOperation.DismissContext(
            viewController: topViewController,
            count: count,
            animation: animation,
            sequential: true
        )

        let operation = NavigationOperation.dismiss(dismissContext)

        return .success([operation])
    }
    
    func makeDismissAllOperation(
        animation: SPNavigationAnimation
    ) -> NavigationOperationItem {
        guard let topViewController = topViewControllerProvider.topViewController else {
            return .failure(.presenterNotFound)
        }

        let dismissAllContext = NavigationOperation.DismissAllContext(
            fromViewController: topViewController,
            animation: animation
        )

        let operation = NavigationOperation.dismissAll(dismissAllContext)

        return .success([operation])
    }
    
    func makeCloseOperation(
        count: Int,
        animation: SPNavigationAnimation
    ) -> NavigationOperationItem {
        guard let topViewController = topViewControllerProvider.topViewController else {
            return .failure(.presenterNotFound)
        }

        let closeContext = NavigationOperation.CloseContext(
            fromViewController: topViewController,
            count: count,
            animation: animation
        )

        let operation = NavigationOperation.close(closeContext)

        return .success([operation])
    }
    
    func makeCloseToOperation(
        targetViewController: UIViewController,
        animation: SPNavigationAnimation
    ) -> NavigationOperationItem {
        guard let topViewController = topViewControllerProvider.topViewController else {
            return .failure(.presenterNotFound)
        }

        let closeToContext = NavigationOperation.CloseToContext(
            fromViewController: topViewController,
            targetViewController: targetViewController,
            animation: animation
        )

        let operation = NavigationOperation.closeTo(closeToContext)

        return .success([operation])
    }

    func makeReplaceTopOperation(
        viewController: UIViewController,
        animation: SPNavigationAnimation
    ) -> NavigationOperationItem {
        guard let navigationController = topNavigationController else {
            return .failure(.navigationControllerNotFound)
        }

        let replaceTopContext = NavigationOperation.ReplaceTopContext(
            viewController: viewController,
            navigationController: navigationController,
            animation: animation
        )

        let operation = NavigationOperation.replaceTop(replaceTopContext)

        return .success([operation])
    }
    
    func makeSetStackOperation(
        viewControllers: [UIViewController],
        animation: SPNavigationAnimation
    ) -> NavigationOperationItem {
        guard let navigationController = topNavigationController else {
            return .failure(.navigationControllerNotFound)
        }

        let setViewControllersContext = NavigationOperation.SetViewControllersContext(
            viewControllers: viewControllers,
            navigationController: navigationController,
            animation: animation
        )

        let operation = NavigationOperation.setViewControllers(setViewControllersContext)

        return .success([operation])
    }
    
}

private extension NavigationOperationFactory {

    var topNavigationController: UINavigationController? {
        guard let topVC = topViewControllerProvider.topViewController else {
            return nil
        }

        return topVC.navigationController ?? (topVC as? UINavigationController)
    }
}
