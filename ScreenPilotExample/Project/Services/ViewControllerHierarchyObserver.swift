import UIKit

@MainActor
final class ViewControllerHierarchyObserver {
    
    private weak var mainWindow: UIWindow?
    private var listeners: [HierarchyListener] = []
    
    init(mainWindow: UIWindow) {
        self.mainWindow = mainWindow
    }
    
    func addListener(_ listener: HierarchyListener) {
        listeners.append(listener)
    }
    
    func removeListener(_ listener: HierarchyListener) {
        listeners.removeAll { $0 === listener }
    }
    
    func notifyHierarchyChanged() {
        let hierarchy = getCurrentHierarchy()
        
        for listener in listeners {
            listener.hierarchyDidChange(hierarchy)
        }
    }
    
    func getCurrentHierarchy() -> String {
        guard let rootViewController = mainWindow?.rootViewController else {
            return "No root view controller found"
        }
        
        return buildHierarchyString(from: rootViewController, level: 0)
    }
    
    private func buildHierarchyString(from viewController: UIViewController, level: Int) -> String {
        let indent = String(repeating: "  ", count: level)
        var result = ""
        
        let vcName = getViewControllerName(viewController)
        result += "\(indent)├─ \(vcName)"
        
        if let navController = viewController as? UINavigationController {
            result += " [\(navController.viewControllers.count)]"
            result += "\n"
            for (index, vc) in navController.viewControllers.enumerated() {
                let isLast = index == navController.viewControllers.count - 1
                let prefix = isLast ? "└─" : "├─"
                let vcName = getViewControllerName(vc)
                result += "\(indent)  \(prefix) \(vcName)"
                if isLast {
                    result += " ⬅︎"
                }
                result += "\n"
            }
        } else {
            result += "\n"
        }
        
        if let presented = viewController.presentedViewController {
            result += "\(indent)  [Modal]\n"
            result += buildHierarchyString(from: presented, level: level + 1)
        }
        
        return result
    }
    
    private func getViewControllerName(_ viewController: UIViewController) -> String {
        if let demoVC = viewController as? DemoViewController {
            return "Screen #\(demoVC.screenNumber)"
        }
        
        let fullName = String(describing: type(of: viewController))
        return fullName.replacingOccurrences(of: "ViewController", with: "VC")
    }
}

@MainActor
protocol HierarchyListener: AnyObject {
    func hierarchyDidChange(_ hierarchy: String)
}
