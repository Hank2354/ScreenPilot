import UIKit

enum NavigationAction {
    case push(count: Int, animated: Bool)
    case modal(count: Int, withNavigation: Bool, animated: Bool)
    
    case pop(count: Int, animated: Bool)
    case popToRoot(animated: Bool)
    case dismiss(count: Int, animated: Bool)
    case dismissAll(animated: Bool)
    case close(count: Int, animated: Bool)
    case closeAll(animated: Bool)
}
