// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Eureka

public struct PrivateKeyRule<T: Equatable>: RuleType {

    public init(msg: String = "Private Key has to be 64 characters long") {
        self.validationError = ValidationError(msg: msg)
    }

    public var id: String?
    public var validationError: ValidationError

    public func isValid(value: T?) -> ValidationError? {
        if let str = value as? String {
            return (str.characters.count != 64) ? validationError : nil
        }
        return value != nil ? nil : validationError
    }
}
