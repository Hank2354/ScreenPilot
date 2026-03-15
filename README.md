# ScreenPilot

A lightweight UIKit navigation library for iOS that provides a unified, async API for push, modal, and complex mixed-hierarchy navigation.

## Requirements

- iOS 16.0+
- Swift 6.0+
- Xcode 15.0+

## Installation

### Swift Package Manager

In Xcode: **File → Add Package Dependencies**, paste the repository URL:

```
https://github.com/vzmashkov/ScreenPilot
```

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/vzmashkov/ScreenPilot", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["ScreenPilot"]
    )
]
```

## Quick Start

### 1. Create the navigator

Provide the root view controller of your app (typically from `UIWindow`):

```swift
import ScreenPilot

let rootProvider = SPRootViewControllerProvider(rootViewController: window.rootViewController!)
let navigator = SPNavigator(rootViewControllerProvider: rootProvider)
```

### 2. Define a screen

Wrap your view controller in an `SPScreenPrototype`:

```swift
let profileScreen = SPScreenPrototype(
    factory: { ProfileViewController() },
    requirements: []
)
```

### 3. Navigate

```swift
// Push
await navigator.navigate(to: [profileScreen], style: .push)

// Present modally
await navigator.navigate(to: [profileScreen], style: .modal(.fullScreen))

// Handle the result
let result = await navigator.navigate(to: [profileScreen], style: .push)
if case .failure(let error) = result {
    print("Navigation failed: \(error)")
}
```

## Navigation Styles

| Style | Description |
|-------|-------------|
| `.push` | Pushes onto the navigation stack |
| `.modal(UIModalPresentationStyle)` | Presents modally with the given presentation style |
| `.replaceTop` | Replaces the top view controller on the navigation stack |
| `.setStack` | Replaces the entire navigation stack |

## Closing Screens

ScreenPilot provides granular control over closing screens:

```swift
// Pop one screen from the stack
await navigator.pop()

// Pop multiple screens
await navigator.pop(count: 3)

// Pop to a specific view controller
await navigator.popTo(homeViewController)

// Pop to the root of the navigation stack
await navigator.popToRoot()

// Dismiss the top modal
await navigator.dismiss()

// Dismiss all modals
await navigator.dismissAll()
```

### `close` — smart mixed-hierarchy closing

`close` intelligently handles hierarchies that mix push and modal navigation:

```swift
// Hierarchy: Root → A → B → Modal(Nav → C → D → E)

await navigator.close(count: 1)  // Closes E
await navigator.close(count: 4)  // Closes E, D, C and the modal — lands on B
await navigator.close(count: 5)  // Closes E, D, C, modal, B — lands on A

await navigator.closeTo(viewControllerA)  // Closes everything back to A
await navigator.closeAll()               // Closes everything back to the root
```

## Animations

All navigation methods accept an optional `SPNavigationAnimation` parameter:

```swift
// Default system animation
await navigator.pop(animation: .default)

// No animation
await navigator.pop(animation: .none)

// Custom UIViewControllerAnimatedTransitioning
let customAnim = SPNavigationAnimation(
    appear: .custom(myAppearTransition),
    disappear: .custom(myDisappearTransition)
)
await navigator.navigate(to: [screen], style: .push, configuration: .init(animation: customAnim))
```

## Navigation Requirements

Guard screens behind custom validation logic using `SPScreenRequirement`:

```swift
struct AuthRequirement: SPScreenRequirement {
    let authService: AuthService

    var isSatisfied: Bool {
        authService.isAuthenticated
    }
}

let profileScreen = SPScreenPrototype(
    factory: { ProfileViewController() },
    requirements: [AuthRequirement(authService: authService)]
)

// If the requirement is not satisfied, navigation returns .failure(.requirementNotSatisfied)
let result = await navigator.navigate(to: [profileScreen], style: .push)
```

## Screen Deduplication

Use `SPNavigationConfiguration` with an `SPScreenFinder` to navigate to an existing screen
in the hierarchy instead of creating a new one:

```swift
let config = SPNavigationConfiguration(screenFinder: SPDefaultScreenFinder())

// If ProfileViewController already exists in the hierarchy, navigates back to it
// instead of pushing a new instance
await navigator.navigate(to: [profileScreen], style: .push, configuration: config)
```

### Context-aware matching

To distinguish between multiple instances of the same screen type, conform your view controller
to `SPScreenContextComparable`:

```swift
class ProductViewController: UIViewController, SPScreenContextComparable {
    let productId: String

    var contextHash: AnyHashable { productId }
}
```

`SPDefaultScreenFinder` will then match both type and `contextHash`, so navigating to
`ProductViewController(productId: "abc")` won't land on `ProductViewController(productId: "xyz")`.

## License

ScreenPilot is available under the MIT license.
