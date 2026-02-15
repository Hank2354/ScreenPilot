import UIKit
import ScreenPilot

@MainActor
final class NavigationManager {
    
    private let navigator: SPNavigator
    private weak var mainWindow: UIWindow?
    private let hierarchyObserver: ViewControllerHierarchyObserver
    
    init(navigator: SPNavigator, mainWindow: UIWindow, hierarchyObserver: ViewControllerHierarchyObserver) {
        self.navigator = navigator
        self.mainWindow = mainWindow
        self.hierarchyObserver = hierarchyObserver
    }
    
    // MARK: - Execute Navigation Action

    func execute(_ action: NavigationAction) async {
        let result: SPNavigationResult

        switch action {
            case .push(let count, let animated):
                result = await openScreens(count: count, style: .push, animated: animated)

            case .modal(let count, let withNavigation, let animated):
                result = await openModalScreens(count: count, withNavigation: withNavigation, animated: animated)

            case .pop(let count, let animated):
                result = await navigator.pop(
                    count: count,
                    animation: animated ? .default : .none
                )
            
            case .popToRoot(let animated):
                result = await navigator.popToRoot(
                    animation: animated ? .default : .none
                )

            case .dismiss(let count, let animated):
                result = await navigator.dismiss(
                    count: count,
                    animation: animated ? .default : .none
                )
            
            case .dismissAll(let animated):
                result = await navigator.dismissAll(
                    animation: animated ? .default : .none
                )
            
            case .close(let count, let animated):
                result = await navigator.close(
                    count: count,
                    animation: animated ? .default : .none
                )
        }

        handleResult(result)
    }
    
    private func getCurrentScreenNumber() -> Int {
        guard let topViewController = getTopViewController() else {
            return 0
        }
        
        if let demoVC = topViewController as? DemoViewController {
            return demoVC.screenNumber
        }
        
        return 0
    }
    
    private func openScreens(count: Int, style: SPNavigationStyle, animated: Bool) async -> SPNavigationResult {
        let currentNumber = getCurrentScreenNumber()
        var screens: [SPScreenPrototype] = []
        
        for i in 0..<count {
            let newNumber = currentNumber + i + 1
            let screen = createDemoScreen(number: newNumber)
            screens.append(screen)
        }
        
        let configuration = SPNavigationConfiguration(
            animation: animated ? .default : .none,
            screenFinder: nil
        )
        
        return await navigator.navigate(to: screens, style: style, configuration: configuration)
    }
    
    private func openModalScreens(count: Int, withNavigation: Bool, animated: Bool) async -> SPNavigationResult {
        let currentNumber = getCurrentScreenNumber()
        
        if withNavigation {
            var screens: [SPScreenPrototype] = []

            for i in 0..<count {
                let newNumber = currentNumber + i + 1
                screens.append(createDemoScreenWithNavigationControler(number: newNumber))
            }
            
            let configuration = SPNavigationConfiguration(
                animation: animated ? .default : .none,
                screenFinder: nil
            )

            return await navigator.navigate(to: screens, style: .modal(.automatic), configuration: configuration)
        } else {
            var screens: [SPScreenPrototype] = []
            
            for i in 0..<count {
                let newNumber = currentNumber + i + 1
                screens.append(createDemoScreen(number: newNumber))
            }
            
            let configuration = SPNavigationConfiguration(
                animation: animated ? .default : .none,
                screenFinder: nil
            )
            
            return await navigator.navigate(to: screens, style: .modal(.pageSheet), configuration: configuration)
        }
    }
    
    private func getTopViewController() -> UIViewController? {
        guard let rootViewController = mainWindow?.rootViewController else {
            return nil
        }
        
        return findTopViewController(from: rootViewController)
    }
    
    private func findTopViewController(from viewController: UIViewController) -> UIViewController {
        if let presented = viewController.presentedViewController {
            return findTopViewController(from: presented)
        }
        
        if let navController = viewController as? UINavigationController {
            if let topVC = navController.topViewController {
                return topVC
            }
        }
        
        if let tabController = viewController as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return findTopViewController(from: selected)
            }
        }
        
        return viewController
    }

    private func createDemoScreen(number: Int) -> SPScreenPrototype {
        return SPScreenPrototype(
            factory: { DemoScreenFactory.createScreen(number: number) },
            requirements: []
        )
    }

    private func createDemoScreenWithNavigationControler(number: Int) -> SPScreenPrototype {
        return SPScreenPrototype(
            factory: { UINavigationController(rootViewController: DemoScreenFactory.createScreen(number: number)) },
            requirements: []
        )
    }

    private func handleResult(_ result: SPNavigationResult) {
        switch result {
        case .success:
            print("✅ Navigation successful")
            hierarchyObserver.notifyHierarchyChanged()
        case .failure(let error):
            print("❌ Navigation failed: \(error)")
        @unknown default:
                return
        }
    }
}
