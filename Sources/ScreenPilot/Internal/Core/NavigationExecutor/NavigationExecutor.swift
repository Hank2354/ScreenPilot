import UIKit

@MainActor
class NavigationExecutor {

    private let closeOperationFactory: CloseOperationFactory
    private let closeToOperationFactory: CloseToOperationFactory
    
    private var retainedDelegates: [ObjectIdentifier: Any] = [:]

    init(
        closeOperationFactory: CloseOperationFactory,
        closeToOperationFactory: CloseToOperationFactory
    ) {
        self.closeOperationFactory = closeOperationFactory
        self.closeToOperationFactory = closeToOperationFactory
    }

    func execute(operation: NavigationOperation) async -> NavigationExecutionResult {
        return switch operation {
            case .push(let context):
                await executePush(context)
            case .pop(let context):
                await executePop(context)
            case .popToRoot(let context):
                await executePopToRoot(context)
            case .popTo(let context):
                await executePopTo(context)
            case .setViewControllers(let context):
                await executeSetViewControllers(context)
            case .replaceTop(let context):
                await executeReplaceTop(context)
            case .present(let context):
                await executePresent(context)
            case .dismiss(let context):
                await executeDismiss(context)
            case .dismissAll(let context):
                await executeDismissAll(context)
            case .close(let context):
                await executeClose(context)
            case .closeTo(let context):
                await executeCloseTo(context)
        }
    }

    func execute(operations: [NavigationOperation]) async -> NavigationExecutionResult {
        for operation in operations {
            let result = await execute(operation: operation)

            switch result {
                case .success:
                    continue
                case .failure(let failure):
                    return .failure(failure)
            }
        }
        return .success
    }
}

private extension NavigationExecutor {

    func executePush(
        _ context: NavigationOperation.PushContext
    ) async -> NavigationExecutionResult {
        guard !context.viewControllers.isEmpty else {
            return .success
        }

        let navController = context.navigationController
        let animated = context.animation.appear != .none
        
        let originalDelegate = navController.delegate
        var proxy: NavigationControllerDelegateProxy?
        
        if case .custom(let animator) = context.animation.appear {
            proxy = NavigationControllerDelegateProxy(
                originalDelegate: originalDelegate,
                pushAnimator: animator,
                popAnimator: nil
            )
            navController.delegate = proxy
            retainedDelegates[ObjectIdentifier(navController)] = proxy
        }
        
        var currentStack = navController.viewControllers
        currentStack.append(contentsOf: context.viewControllers)

        await withCheckedContinuation { continuation in
            navController.setViewControllers(currentStack, animated: animated) {
                continuation.resume()
            }
        }
        
        if proxy != nil {
            navController.delegate = originalDelegate
            retainedDelegates.removeValue(forKey: ObjectIdentifier(navController))
        }

        return .success
    }

    func executePresent(
        _ context: NavigationOperation.PresentContext
    ) async -> NavigationExecutionResult {
        guard !context.viewControllers.isEmpty else {
            return .success
        }

        var currentPresenter = context.presenter
        let animated = context.animation.appear != .none

        for viewController in context.viewControllers {
            viewController.modalPresentationStyle = context.presentationStyle
            
            var transitioningDelegate: PresentationTransitioningDelegate?
            
            if case .custom(let presentAnimator) = context.animation.appear {
                let dismissAnimator: UIViewControllerAnimatedTransitioning?
                if case .custom(let animator) = context.animation.disappear {
                    dismissAnimator = animator
                } else {
                    dismissAnimator = nil
                }
                
                transitioningDelegate = PresentationTransitioningDelegate(
                    presentAnimator: presentAnimator,
                    dismissAnimator: dismissAnimator
                )
                viewController.transitioningDelegate = transitioningDelegate
                retainedDelegates[ObjectIdentifier(viewController)] = transitioningDelegate
            }

            await withCheckedContinuation { continuation in
                currentPresenter.present(viewController, animated: animated) {
                    continuation.resume()
                }
            }

            currentPresenter = viewController
        }

        return .success
    }

    func executeSetViewControllers(
        _ context: NavigationOperation.SetViewControllersContext
    ) async -> NavigationExecutionResult {
        let animated = context.animation.appear != .none
        
        await withCheckedContinuation { continuation in
            context.navigationController.setViewControllers(
                context.viewControllers,
                animated: animated
            ) {
                continuation.resume()
            }
        }

        return .success
    }

    func executeReplaceTop(
        _ context: NavigationOperation.ReplaceTopContext
    ) async -> NavigationExecutionResult {
        var viewControllers = context.navigationController.viewControllers
        let animated = context.animation.appear != .none

        if !viewControllers.isEmpty {
            viewControllers.removeLast()
        }
        viewControllers.append(context.viewController)

        await withCheckedContinuation { continuation in
            context.navigationController.setViewControllers(
                viewControllers,
                animated: animated
            ) {
                continuation.resume()
            }
        }

        return .success
    }

    func executePop(
        _ context: NavigationOperation.PopContext
    ) async -> NavigationExecutionResult {
        let navController = context.navigationController
        let viewControllers = navController.viewControllers
        let currentCount = viewControllers.count

        guard currentCount > 1 else {
            return .failure(.impossiblePop)
        }

        let targetIndex = max(0, currentCount - context.count - 1)
        let targetViewController = viewControllers[targetIndex]
        let animated = context.animation.disappear != .none
        
        let originalDelegate = navController.delegate
        var proxy: NavigationControllerDelegateProxy?
        
        if case .custom(let animator) = context.animation.disappear {
            proxy = NavigationControllerDelegateProxy(
                originalDelegate: originalDelegate,
                pushAnimator: nil,
                popAnimator: animator
            )
            navController.delegate = proxy
            retainedDelegates[ObjectIdentifier(navController)] = proxy
        }

        await withCheckedContinuation { continuation in
            navController.popToViewController(targetViewController, animated: animated) {
                continuation.resume()
            }
        }
        
        if proxy != nil {
            navController.delegate = originalDelegate
            retainedDelegates.removeValue(forKey: ObjectIdentifier(navController))
        }

        return .success
    }

    func executePopToRoot(
        _ context: NavigationOperation.PopToRootContext
    ) async -> NavigationExecutionResult {
        let navController = context.navigationController
        let animated = context.animation.disappear != .none
        
        let originalDelegate = navController.delegate
        var proxy: NavigationControllerDelegateProxy?
        
        if case .custom(let animator) = context.animation.disappear {
            proxy = NavigationControllerDelegateProxy(
                originalDelegate: originalDelegate,
                pushAnimator: nil,
                popAnimator: animator
            )
            navController.delegate = proxy
            retainedDelegates[ObjectIdentifier(navController)] = proxy
        }
        
        await withCheckedContinuation { continuation in
            navController.popToRootViewController(animated: animated) {
                continuation.resume()
            }
        }
        
        if proxy != nil {
            navController.delegate = originalDelegate
            retainedDelegates.removeValue(forKey: ObjectIdentifier(navController))
        }

        return .success
    }

    func executePopTo(
        _ context: NavigationOperation.PopToContext
    ) async -> NavigationExecutionResult {
        let navController = context.navigationController
        
        guard navController.viewControllers.contains(context.targetViewController) else {
            return .failure(.viewControllerNotInStack)
        }

        let animated = context.animation.disappear != .none
        
        let originalDelegate = navController.delegate
        var proxy: NavigationControllerDelegateProxy?
        
        if case .custom(let animator) = context.animation.disappear {
            proxy = NavigationControllerDelegateProxy(
                originalDelegate: originalDelegate,
                pushAnimator: nil,
                popAnimator: animator
            )
            navController.delegate = proxy
            retainedDelegates[ObjectIdentifier(navController)] = proxy
        }

        await withCheckedContinuation { continuation in
            navController.popToViewController(
                context.targetViewController,
                animated: animated
            ) {
                continuation.resume()
            }
        }
        
        if proxy != nil {
            navController.delegate = originalDelegate
            retainedDelegates.removeValue(forKey: ObjectIdentifier(navController))
        }

        return .success
    }

    func executeDismiss(
        _ context: NavigationOperation.DismissContext
    ) async -> NavigationExecutionResult {
        let animated = context.animation.disappear != .none
        
        if context.sequential {
            var current: UIViewController? = context.viewController

            for _ in 0..<context.count {
                guard let viewController = current else { break }
                let presenting = viewController.presentingViewController

                await withCheckedContinuation { continuation in
                    viewController.dismiss(animated: animated) {
                        continuation.resume()
                    }
                }

                current = presenting?.presentedViewController
            }
        } else {
            var target: UIViewController? = context.viewController

            for _ in 1..<context.count {
                guard let presentingVC = target?.presentingViewController else { break }
                target = presentingVC
            }

            guard let dismissFrom = target else {
                return .success
            }

            await withCheckedContinuation { continuation in
                dismissFrom.dismiss(animated: animated) {
                    continuation.resume()
                }
            }
        }

        return .success
    }

    func executeDismissAll(
        _ context: NavigationOperation.DismissAllContext
    ) async -> NavigationExecutionResult {
        var current: UIViewController? = context.fromViewController
        while let presented = current?.presentingViewController {
            current = presented
        }

        guard let root = current, root.presentedViewController != nil else {
            return .success
        }

        let animated = context.animation.disappear != .none

        await withCheckedContinuation { continuation in
            root.dismiss(animated: animated) {
                continuation.resume()
            }
        }

        return .success
    }

    func executeClose(
        _ context: NavigationOperation.CloseContext
    ) async -> NavigationExecutionResult {
        let operations = closeOperationFactory.makeOperations(
            from: context.fromViewController,
            count: context.count,
            animation: context.animation
        )

        for operation in operations {
            let result = await execute(operation: operation)
            if case .failure(let error) = result {
                return .failure(error)
            }
        }

        return .success
    }
    
    func executeCloseTo(
        _ context: NavigationOperation.CloseToContext
    ) async -> NavigationExecutionResult {
        guard let operations = closeToOperationFactory.makeOperations(
            from: context.fromViewController,
            to: context.targetViewController,
            animation: context.animation
        ) else {
            return .failure(.viewControllerNotInHierarchy)
        }
        
        for operation in operations {
            let result = await execute(operation: operation)
            if case .failure(let error) = result {
                return .failure(error)
            }
        }
        
        return .success
    }
}
