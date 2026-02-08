import UIKit.UIViewController

/**
 A prototype of the screen that will be used for navigation

 ## Overview
 This type is designed to encapsulate all the data of the target screen to which navigation is performed, including the requirements that must be met to open it

 - parameter factory: Closure for creation screen target UIViewController
 - parameter requirements: The requirements that must be met to open it
 */
public final class SPScreenPrototype: Sendable {
    public typealias NavigationFactory = @Sendable () -> UIViewController

    let factory: NavigationFactory
    let requirements: [SPScreenRequirement]

    public init(
        factory: @escaping NavigationFactory,
        requirements: [SPScreenRequirement]
    ) {
        self.factory = factory
        self.requirements = requirements
    }
}
