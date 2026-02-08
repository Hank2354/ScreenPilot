/**
 A protocol representing a precondition that must be satisfied before navigating to a screen.

 ## Overview
 `SPScreenRequirement` allows you to define custom validation logic that must pass before
 a screen can be opened. Requirements are checked by `SPNavigator` before executing navigation.
 If any requirement fails, the navigation is cancelled and returns a `.failure` result with
 `.requirementNotSatisfied` error.

 Common use cases include checking authentication status, feature flags, network connectivity,
 or any other business logic that determines whether a screen should be accessible.

 - Important: All requirements must return `true` from `isSatisified` for navigation to proceed.
   Requirements are evaluated synchronously, so avoid performing heavy operations in this property.
   Consider using async validation before calling the navigator if needed.

 # Example #
 ```swift
 struct AuthenticationRequirement: SPScreenRequirement {
     let authService: AuthService

     var isSatisified: Bool {
         return authService.isAuthenticated
     }
 }

 struct FeatureFlagRequirement: SPScreenRequirement {
     let featureName: String
     let flagService: FeatureFlagService

     var isSatisified: Bool {
         return flagService.isEnabled(featureName)
     }
 }

 // Use in screen prototype
 let profileScreen = SPScreenPrototype(
     factory: { ProfileViewController() },
     requirements: [
         AuthenticationRequirement(authService: authService),
         FeatureFlagRequirement(featureName: "profile_v2", flagService: flagService)
     ]
 )
 ```
 */
public protocol SPScreenRequirement: Sendable {
    var isSatisfied: Bool { get }
}
