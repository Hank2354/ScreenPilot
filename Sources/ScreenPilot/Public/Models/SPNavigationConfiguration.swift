public struct SPNavigationConfiguration: Sendable {
    let animation: SPNavigationAnimation
    let screenFinder: SPScreenFinder?

    public init(
        animation: SPNavigationAnimation = .default,
        screenFinder: SPScreenFinder? = nil
    ) {
        self.animation = animation
        self.screenFinder = screenFinder
    }
    
    public static let `default` = SPNavigationConfiguration()
}
