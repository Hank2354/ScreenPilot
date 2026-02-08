/**
 A protocol that allows view controllers to provide additional context for screen matching.

 ## Overview
 When using `SPScreenFinder` to locate existing screens in the navigation hierarchy,
 the finder first matches by view controller type. If the screen conforms to `SPScreenContextComparable`,
 the finder will also compare `contextHash` values to distinguish between multiple instances
 of the same view controller type with different contexts (e.g., profile screens for different users).

 - Important: The `contextHash` should uniquely identify the screen's context. Two screens of the same
   type with identical `contextHash` values are considered the same screen. Use this to prevent
   opening duplicate screens with the same data.

 # Example #
 ```swift
 class ProfileViewController: UIViewController, SPScreenContextComparable {
     let userId: String

     var contextHash: AnyHashable {
         return userId
     }

     init(userId: String) {
         self.userId = userId
         super.init(nibName: nil, bundle: nil)
     }
 }
 ```

 When navigating, if a ProfileViewController with the same userId
 already exists, the navigator will navigate to it instead of creating a new one
*/
public protocol SPScreenContextComparable {
    var contextHash: AnyHashable { get }
}
