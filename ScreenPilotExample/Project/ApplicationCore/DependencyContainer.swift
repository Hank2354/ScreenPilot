import UIKit
import ScreenPilot

final class DependencyContainer {

    private var mainWindow: UIWindow
    private let sharedInstanceLock = NSLock()
    private var sharedInstances = [String: Any]()

    init(mainWindow: UIWindow) {
        self.mainWindow = mainWindow
    }

    @MainActor
    var viewControllerHierarchyObserver: ViewControllerHierarchyObserver {
        shared {
            ViewControllerHierarchyObserverImpl(
                mainWindow: mainWindow
            )
        }
    }

    @MainActor
    var navigationManager: NavigationManager {
        NavigationManagerImpl(
            mainWindow: mainWindow,
            navigator: spNavigator,
            demoScreenFactory: demoScreenFactory,
            hierarchyObserver: viewControllerHierarchyObserver
        )
    }

    @MainActor
    var demoScreenFactory: DemoScreenFactory {
        DemoScreenFactoryImpl()
    }
}

private extension DependencyContainer {

    @MainActor
    var rootViewController: UIViewController {
        guard let rootViewController = mainWindow.rootViewController else {
            fatalError("The main window must contain a rootViewController")
        }

        return rootViewController
    }

    @MainActor
    var spNavigator: SPNavigator {
        SPNavigator(
            rootViewControllerProvider: spRootViewControllerProvider
        )
    }

    @MainActor
    var spRootViewControllerProvider: SPRootViewControllerProvider {
        SPRootViewControllerProvider(
            rootViewController: rootViewController
        )
    }
}

private extension DependencyContainer {
    func shared<T>(function: String = #function, _ factory: () -> T) -> T {
        sharedInstanceLock.withLock {
            guard let instance = (sharedInstances[function] as? T?) ?? nil else {
                let instance = factory()
                sharedInstances[function] = instance
                return instance
            }

            return instance
        }
    }
}
