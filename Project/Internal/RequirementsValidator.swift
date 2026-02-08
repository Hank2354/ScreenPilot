protocol RequirementsValidator {

    func validate(_ requirements: [SPScreenRequirement]) -> Bool
}

class RequirementsValidatorImpl: RequirementsValidator {

    func validate(_ requirements: [SPScreenRequirement]) -> Bool {
        for requirement in requirements {
            if !requirement.isSatisified {
                return false
            }
        }

        return true
    }
}
