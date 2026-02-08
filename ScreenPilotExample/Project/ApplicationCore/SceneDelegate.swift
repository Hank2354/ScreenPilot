import UIKit
import ScreenPilot

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var debugWindow: UIWindow?
    private var debugButton: DebugButton?
    private var overlayView: OverlayView?
    private var isOverlayVisible = false
    private var navigationManager: NavigationManager?

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
        
        setupNavigator(rootViewController: rootViewController)
        setupDebugButton()
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
    
    private func setupNavigator(rootViewController: UIViewController) {
        guard let mainWindow = window else { return }
        
        let rootProvider = SPRootViewControllerProvider(rootViewController: rootViewController)
        let navigator = SPNavigator(rootViewControllerProvider: rootProvider)
        self.navigationManager = NavigationManager(navigator: navigator, mainWindow: mainWindow)
    }

    private func setupDebugButton() {
        guard let windowScene = window?.windowScene else { return }

        // Создаем отдельный window для debug UI поверх всего
        let debugWindow = UIWindow(windowScene: windowScene)
        debugWindow.windowLevel = .alert + 1
        debugWindow.backgroundColor = .clear
        debugWindow.isUserInteractionEnabled = true
        
        // Создаем прозрачный root view controller
        let rootVC = UIViewController()
        rootVC.view.backgroundColor = .clear
        debugWindow.rootViewController = rootVC
        debugWindow.makeKeyAndVisible()
        
        // Возвращаем key window обратно к основному окну
        window?.makeKey()

        let overlayView = OverlayView(frame: debugWindow.bounds)
        overlayView.translatesAutoresizingMaskIntoConstraints = false

        let debugButton = DebugButton()
        debugButton.translatesAutoresizingMaskIntoConstraints = false

        rootVC.view.addSubview(overlayView)
        rootVC.view.addSubview(debugButton)

        debugButton.widthAnchor.constraint(equalToConstant: 62).isActive = true
        debugButton.heightAnchor.constraint(equalTo: debugButton.widthAnchor).isActive = true
        debugButton.leadingAnchor.constraint(equalTo: rootVC.view.leadingAnchor).isActive = true
        debugButton.bottomAnchor.constraint(equalTo: rootVC.view.bottomAnchor, constant: -60).isActive = true

        overlayView.leadingAnchor.constraint(equalTo: rootVC.view.leadingAnchor).isActive = true
        overlayView.topAnchor.constraint(equalTo: rootVC.view.topAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: rootVC.view.trailingAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: rootVC.view.bottomAnchor).isActive = true

        debugButton.onTap { [weak self] in
            self?.toggleOverlay()
        }
        
        overlayView.onClose = { [weak self] in
            self?.toggleOverlay()
        }
        
        overlayView.onNavigationAction = { [weak self] action in
            self?.handleNavigationAction(action)
        }
        
        overlayView.onRefreshHierarchy = { [weak self] in
            return self?.navigationManager?.getHierarchy() ?? "No hierarchy available"
        }

        self.debugWindow = debugWindow
        self.overlayView = overlayView
        self.debugButton = debugButton
    }
    
    private func toggleOverlay() {
        guard let overlayView = overlayView else { return }
        
        if isOverlayVisible {
            overlayView.hide()
            isOverlayVisible = false
        } else {
            overlayView.show()
            isOverlayVisible = true
        }
    }
    
    private func handleNavigationAction(_ action: NavigationAction) {
        Task { @MainActor in
            await navigationManager?.execute(action)
        }
    }
}

