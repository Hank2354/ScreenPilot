import UIKit

public struct SPNavigationAnimation: Equatable, Sendable {
    let appear: AnimationType
    let disappear: AnimationType
    
    public enum AnimationType: Equatable, @unchecked Sendable {
        case `default`
        case none
        case custom(UIViewControllerAnimatedTransitioning)
    }
    
    public init(appear: AnimationType, disappear: AnimationType) {
        self.appear = appear
        self.disappear = disappear
    }
}

public extension SPNavigationAnimation {
    static let `default` = SPNavigationAnimation(appear: .default, disappear: .default)
    static let none = SPNavigationAnimation(appear: .none, disappear: .none)
}

public extension SPNavigationAnimation.AnimationType {
    static func == (
        lhs: SPNavigationAnimation.AnimationType,
        rhs: SPNavigationAnimation.AnimationType
    ) -> Bool {
        switch (lhs, rhs) {
            case (.default, .default):
                return true
            case (.none, .none):
                return true
            case (.custom(let lhsTransitioning), .custom(let rhsTransitioning)):
                return lhsTransitioning.isEqual(rhsTransitioning)
            case (.default, _):
                return false
            case (.none, _):
                return false
            case (.custom, _):
                return false
        }
    }
}
