import UIKit

/**
 A protocol for finding existing screens in the navigation hierarchy.

  ## Overview
  `SPScreenFinder` defines a strategy for locating view controllers in the current navigation hierarchy.
  It is used by `SPNavigator` to determine if a screen already exists before creating a new one.
  This enables intelligent navigation that reuses existing screens instead of duplicating them.

 The default implementation is `SPDefaultScreenFinder`, which matches screens by their type
 and optionally by context (if they conform to `SPScreenContextComparable`).

  - Important: Implementations should search through the entire navigation hierarchy, including
    navigation stacks, modals, and tab bars. The search starts from `topViewController` and
    should traverse backwards through presenting view controllers and navigation stacks.

  # Example #
 ```swift
 // Use the built-in default finder
 let finder = SPDefaultScreenFinder()

 let config = SPNavigationConfiguration(
     screenFinder: finder,
     animation: .default
 )

 // If ProfileViewController already exists in the hierarchy,
 // navigate to it instead of creating a new one
 await navigator.navigate(
     to: [profileScreen],
     style: .push,
     configuration: config
 )
 ```

 */
@MainActor
public protocol SPScreenFinder: Sendable {
    func findScreen(
        matching screen: UIViewController,
        startingFrom topViewController: UIViewController
    ) -> UIViewController?
}
