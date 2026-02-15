import UIKit
import ScreenPilot

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var debugWindow: UIWindow?
    private var navigationManager: NavigationManager?
    private var hierarchyObserver: ViewControllerHierarchyObserver?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let newWindow = UIWindow(windowScene: windowScene)
        window = newWindow

        let rootViewController = makeInitialScreen()
        setupWindow(newWindow, rootViewController: rootViewController)

        let hierarchyObserver = ViewControllerHierarchyObserver(mainWindow: newWindow)
        self.hierarchyObserver = hierarchyObserver
        
        let navigationManager = makeNavigationManager(rootViewController: rootViewController, window: newWindow, hierarchyObserver: hierarchyObserver)
        self.navigationManager = navigationManager

        setupDebugWindow(navigationManager: navigationManager, hierarchyObserver: hierarchyObserver)
    }

    private func makeInitialScreen() -> UIViewController {
        let initialViewController = InitialViewController()
        let initialNavigationController = UINavigationController(rootViewController: initialViewController)

        initialNavigationController.navigationBar.prefersLargeTitles = true

        return initialNavigationController
    }

    private func setupWindow(_ window: UIWindow, rootViewController: UIViewController) {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }

    private func makeNavigationManager(rootViewController: UIViewController, window: UIWindow, hierarchyObserver: ViewControllerHierarchyObserver) -> NavigationManager {
        let rootProvider = SPRootViewControllerProvider(rootViewController: rootViewController)
        let navigator = SPNavigator(rootViewControllerProvider: rootProvider)

        return NavigationManager(navigator: navigator, mainWindow: window, hierarchyObserver: hierarchyObserver)
    }

    private func setupDebugWindow(navigationManager: NavigationManager, hierarchyObserver: ViewControllerHierarchyObserver) {
        guard let windowScene = window?.windowScene else { return }

        let debugWindow = UIWindow(windowScene: windowScene)
        debugWindow.windowLevel = .alert + 1
        debugWindow.backgroundColor = .clear
        debugWindow.isUserInteractionEnabled = true

        let debugViewController = DebugViewController(navigationManager: navigationManager, hierarchyObserver: hierarchyObserver)
        debugWindow.rootViewController = debugViewController
        debugWindow.makeKeyAndVisible()

        self.debugWindow = debugWindow

        window?.makeKey()
    }
}

