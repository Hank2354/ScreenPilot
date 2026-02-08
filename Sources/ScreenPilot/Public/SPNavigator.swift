import UIKit

/**
 The main object responsible for navigation within the application.

 ## Overview
 `SPNavigator` provides a unified API for all navigation operations including pushing,
 presenting, popping, dismissing, and more complex operations like `close` and `closeTo`
 that intelligently handle mixed navigation hierarchies.

 - important: Create a `SPNavigator` instance by providing a `SPRootViewControllerProvider` that supplies
 the root view controller of your navigation hierarchy

 # Example #
 ```swift
 let rootProvider = SPRootViewControllerProvider(rootViewController: window.rootViewController)

 let navigator = SPNavigator(rootViewControllerProvider: rootProvider)
 ```

*/
@MainActor
public class SPNavigator {

    private let requirementsValidator: RequirementsValidator
    private let operationFactory: NavigationOperationFactory
    private let executor: NavigationExecutor
    private let topViewControllerProvider: TopViewControllerProvider

    /**
     Creates a new navigator instance.

     - parameter rootViewControllerProvider: A provider that supplies the root view controller. from which the navigation hierarchy analysis begins.
    */
    public convenience init(rootViewControllerProvider: SPRootViewControllerProvider) {
        let requirementsValidator = RequirementsValidatorImpl()
        let topViewControllerProvider = TopViewControllerProviderImpl(
            rootViewControllerProvider: rootViewControllerProvider
        )
        let hierarchyHelper = ViewControllerHierarchyHelperImpl()
        let closeOperationFactory = CloseOperationFactory(hierarchyHelper: hierarchyHelper)
        let closeToOperationFactory = CloseToOperationFactory(hierarchyHelper: hierarchyHelper)

        self.init(
            requirementsValidator: requirementsValidator,
            operationFactory: NavigationOperationFactory(
                topViewControllerProvider: topViewControllerProvider
            ),
            executor: NavigationExecutor(
                closeOperationFactory: closeOperationFactory,
                closeToOperationFactory: closeToOperationFactory
            ),
            topViewControllerProvider: topViewControllerProvider
        )
    }

    init(
        requirementsValidator: RequirementsValidator,
        operationFactory: NavigationOperationFactory,
        executor: NavigationExecutor,
        topViewControllerProvider: TopViewControllerProvider
    ) {
        self.requirementsValidator = requirementsValidator
        self.operationFactory = operationFactory
        self.executor = executor
        self.topViewControllerProvider = topViewControllerProvider
    }

    // MARK: - Opening Screens

    /**
     Navigates to the specified screens using the given navigation style.

     ## Overview
     This method validates all screen requirements before navigation. If a `SPScreenFinder`
     is provided in the configuration and finds an existing matching screen in the hierarchy,
     it will navigate back to that screen instead of opening a new one

     - Parameters:
       - screens: An array of screen prototypes to navigate to
       - style: The navigation style to apply
       - configuration: Additional configuration. Defaults to `.default`

     - returns: A `SPNavigationResult` indicating success or failure with an associated error

     - Important: The navigation style is applied to all screens in the array. For `.push`,
       all screens are added to the navigation stack. For `.modal`, screens are presented
       sequentially one after another

     # Example #
     ```swift
     **Basic push navigation:**
     let profileScreen = SPScreenPrototype(
         factory: { ProfileViewController() },
         requirements: []
     )

     await navigator.navigate(to: [profileScreen], style: .push)
     ```

     */
    public func navigate(
        to screens: [SPScreenPrototype],
        style: SPNavigationStyle,
        configuration: SPNavigationConfiguration = .default
    ) async -> SPNavigationResult {
        guard !screens.isEmpty else {
            return .failure(.emptyScreenList)
        }
        
        if let error = validateRequirements(for: screens) {
            return .failure(error)
        }
        
        let viewControllers = screens.map { $0.factory() }

        guard let firstViewController = viewControllers.first else {
            return .failure(.emptyScreenList)
        }

        if let screenFinder = configuration.screenFinder,
           let existingViewController = await findScreen(screenFinder, for: firstViewController) {
            return await closeTo(existingViewController, animation: configuration.animation)
        }

        let item = switch style {
            case .push:
                operationFactory.makePushOperation(
                    viewControllers: viewControllers,
                    animation: configuration.animation
                )
            case .modal(let presentationStyle):
                operationFactory.makePresentOperation(
                    viewControllers: viewControllers,
                    style: presentationStyle,
                    animation: configuration.animation
                )
            case .replaceTop:
                operationFactory.makeReplaceTopOperation(
                    viewController: firstViewController,
                    animation: configuration.animation
                )
            case .setStack:
                operationFactory.makeSetStackOperation(
                    viewControllers: viewControllers,
                    animation: configuration.animation
                )
        }
        
        return await process(item)
    }

    // MARK: - Closing Screens

    /**
     Pops the specified number of view controllers from the navigation stack.

     - Parameters:
       - count: The number of view controllers to pop. Defaults to `1`.
       - animation: The animation configuration for the transition. Defaults to `.default`.

     - Returns: A `SPNavigationResult` indicating success or failure.

     # Example #
     **Pop single screen:**
     ```swift
     await navigator.pop()
     ```
     **Pop multiple screens:**
     ```swift
     await navigator.pop(count: 3)
     ```
     **Pop without animation:**
     ```swift
     await navigator.pop(animation: .none)
     ```
     */
    public func pop(
        count: Int = 1,
        animation: SPNavigationAnimation = .default
    ) async -> SPNavigationResult {
        let item = operationFactory.makePopOperation(
            count: count,
            animation: animation
        )
        return await process(item)
    }

    /**
    Pops view controllers until the specified view controller is at the top of the navigation stack.

    - Parameters:
      - viewController: The target view controller to pop to. Must be in the current navigation stack.
      - animation: The animation configuration for the transition. Defaults to `.default`

    - Returns: A `SPNavigationResult` indicating success or failure.

    - Important: Returns `.failure(.viewControllerNotInStack)`
     if the target view controller is not found in the navigation stack

    ## Example

    ```swift
    // Store reference to a view controller
    let homeViewController = HomeViewController()

    // Later, pop back to it
    await navigator.popTo(homeViewController)
    ```
    */
    public func popTo(
        _ viewController: UIViewController,
        animation: SPNavigationAnimation = .default
    ) async -> SPNavigationResult {
        let item = operationFactory.makePopToOperation(
            viewController: viewController,
            animation: animation
        )
        return await process(item)
    }

    /**
    Pops all view controllers except the root view controller of the navigation stack.

    - Parameter animation: The animation configuration for the transition. Defaults to `.default`.

    - Returns: A `SPNavigationResult` indicating success or failure.

    ## Example

    ```swift
    // Return to the root of the navigation stack
    await navigator.popToRoot()
    ```
    */
    public func popToRoot(
        animation: SPNavigationAnimation = .default
    ) async -> SPNavigationResult {
        let item = operationFactory.makePopToRootOperation(
            animation: animation
        )
        return await process(item)
    }

    /**
    Dismisses the specified number of modally presented view controllers.

    - Parameters:
      - count: The number of modal presentations to dismiss. Defaults to `1`.
      - animation: The animation configuration for the transition. Defaults to `.default`.

    - Returns: A `SPNavigationResult` indicating success or failure.

    ## Examples

    **Dismiss single modal:**
    ```swift
    await navigator.dismiss()
    ```

    **Dismiss multiple modals:**
    ```swift
    // If you have Modal1 -> Modal2, this dismisses all two
    await navigator.dismiss(count: 2)
    ```
    */
    public func dismiss(
        count: Int = 1,
        animation: SPNavigationAnimation = .default
    ) async -> SPNavigationResult {
        let item = operationFactory.makeDismissOperation(
            count: count,
            animation: animation
        )
        return await process(item)
    }

    /**
    Dismisses all modally presented view controllers.

    This method finds the root presenting view controller and dismisses from there,
    effectively closing all modal presentations in one operation.

    - Parameter animation: The animation configuration for the transition. Defaults to `.default`.

    - Returns: A `SPNavigationResult` indicating success or failure.

    ## Example

    ```swift
    // Close all modals regardless of how many are presented
    await navigator.dismissAll()
    ```
    */
    public func dismissAll(
        animation: SPNavigationAnimation = .default
    ) async -> SPNavigationResult {
        let item = operationFactory.makeDismissAllOperation(
            animation: animation
        )
        return await process(item)
    }

    /**
    Closes the specified number of screens, intelligently handling both push and modal navigation.

    This method analyzes the current navigation hierarchy and determines the appropriate
    combination of pop and dismiss operations needed to close the requested number of screens.
    It properly accounts for navigation stacks within modals.

    - Parameters:
      - count: The number of screens to close. Defaults to `1`.
      - animation: The animation configuration for the transition. Defaults to `.default`.

    - Returns: A `SPNavigationResult` indicating success or failure.

    ## Example

    Consider a hierarchy:

    **Root -> A -> B -> Modal(Nav -> C -> D -> E)**

    ```swift
    // Closes E (pops within modal)
    await navigator.close(count: 1)

    // Closes E, D, C and the modal, landing on B
    await navigator.close(count: 4)

    // Closes E, D, C, modal, B, landing on A
    await navigator.close(count: 5)
    ```
    */
    public func close(
        count: Int = 1,
        animation: SPNavigationAnimation = .default
    ) async -> SPNavigationResult {
        let item = operationFactory.makeCloseOperation(
            count: count,
            animation: animation
        )
        return await process(item)
    }

    /**
    Closes all screens until the specified view controller becomes the top visible screen.

    This method works like ``close(count:animation:)`` but targets a specific view controller
    instead of a count. It handles both push stacks and modal presentations, executing
    the necessary combination of pop and dismiss operations.

    - Parameters:
      - viewController: The target view controller to navigate back to.
      - animation: The animation configuration for the transition. Defaults to `.default`.

    - Returns: A `SPNavigationResult` indicating success or failure. Returns
      `.failure(.viewControllerNotInHierarchy)` if the target is not found.

    ## Example

    Consider a hierarchy: `Root -> A -> B -> Modal(Nav -> C -> D)`

    ```swift
    // Store reference to screen A
    let screenA = ScreenAViewController()

    // Later, from screen D, close everything back to A
    // This will: dismiss the modal, then pop B
    await navigator.closeTo(screenA)
    ```
    */
    public func closeTo(
        _ viewController: UIViewController,
        animation: SPNavigationAnimation = .default
    ) async -> SPNavigationResult {
        let item = operationFactory.makeCloseToOperation(
            targetViewController: viewController,
            animation: animation
        )
        return await process(item)
    }
}

private extension SPNavigator {

    func validateRequirements(for screens: [SPScreenPrototype]) -> SPNavigationError? {
        let requirements = screens.flatMap { $0.requirements }
        guard requirementsValidator.validate(requirements) else {
            return .requirementNotSatisfied(screens: screens, failedRequirements: requirements)
        }
        return nil
    }

    func findScreen(
        _ screenFinder: SPScreenFinder,
        for viewController: UIViewController
    ) async -> UIViewController? {
        guard let topViewController = topViewControllerProvider.topViewController else {
            return nil
        }

        return screenFinder.findScreen(
            matching: viewController,
            startingFrom: topViewController
        )
    }
    
    func process(_ item: NavigationOperationItem) async -> SPNavigationResult {
        switch item {

        case .success(let operations):
            let executionResult = await executor.execute(operations: operations)

            switch executionResult {
            case .success:
                return .success
            case .failure(let error):
                return .failure(error.toSPNavigationError)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}

private extension NavigationExecutionError {
    var toSPNavigationError: SPNavigationError {
        switch self {
        case .viewControllerNotInStack:
            return .viewControllerNotInStack
        case .viewControllerNotInHierarchy:
            return .viewControllerNotInHierarchy
        case .impossiblePop:
            return .impossiblePop
        }
    }
}
