import UIKit
import ScreenPilot

final class DependencyContainer {

    private var mainWindow: UIWindow

    init(mainWindow: UIWindow) {
        self.mainWindow = mainWindow
    }

    @MainActor
    var viewControllerHierarchyObserver: ViewControllerHierarchyObserver {
        ViewControllerHierarchyObserverImpl(
            mainWindow: mainWindow
        )
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
