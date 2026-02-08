public enum SPNavigationError: Error {
    case requirementNotSatisfied(screens: [SPScreenPrototype], failedRequirements: [SPScreenRequirement])
    case emptyScreenList
    case navigationControllerNotFound
    case presenterNotFound
    case impossiblePop
    case viewControllerNotInStack
    case viewControllerNotInHierarchy
}
