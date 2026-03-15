import UIKit
import ScreenPilot

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var debugWindow: UIWindow!
    private var dependencyContainer: DependencyContainer!

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let newWindow = makeMainWindow(windowScene: windowScene)
        window = newWindow

        debugWindow = makeDebugWindow(windowScene: windowScene)

        let rootViewController = makeInitialScreen()
        setupWindow(newWindow, rootViewController: rootViewController)

        dependencyContainer = DependencyContainer(mainWindow: newWindow)

        let debugViewController = makeDebugScreen()
        setupWindow(debugWindow, rootViewController: debugViewController)

        window?.makeKey()
    }
}

// MARK: - Factories
private extension SceneDelegate {
    private func makeMainWindow(windowScene: UIWindowScene) -> UIWindow {
        UIWindow(windowScene: windowScene)
    }

    private func makeDebugWindow(windowScene: UIWindowScene) -> UIWindow {
        PassthroughDebugWindow(windowScene: windowScene)
    }

    private func makeInitialScreen() -> UIViewController {
        let firstInitialViewController = InitialViewController(tabIndex: 0)
        let secondInitialViewController = InitialViewController(tabIndex: 1)

        let firstInitialNavigationController = UINavigationController(rootViewController: firstInitialViewController)
        let secondInitialNavigationController = UINavigationController(rootViewController: secondInitialViewController)

        firstInitialNavigationController.navigationBar.prefersLargeTitles = true
        secondInitialNavigationController.navigationBar.prefersLargeTitles = true

        let tabBarViewController = UITabBarController()

        tabBarViewController.setViewControllers(
            [firstInitialNavigationController, secondInitialNavigationController],
            animated: false
        )

        return tabBarViewController
    }

    private func makeDebugScreen() -> UIViewController {
        DebugViewController(
            navigationManager: dependencyContainer.navigationManager,
            hierarchyObserver: dependencyContainer.viewControllerHierarchyObserver
        )
    }
}

// MARK: - Helpers
private extension SceneDelegate {
    private func setupWindow(_ window: UIWindow, rootViewController: UIViewController) {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
}
