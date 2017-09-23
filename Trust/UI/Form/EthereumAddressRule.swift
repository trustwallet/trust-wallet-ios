// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import Eureka

public struct EthereumAddressRule<T: Equatable>: RuleType {

    public init(msg: String = "Invalid Ethereum Address") {
        self.validationError = ValidationError(msg: msg)
    }

    public var id: String?
    public var validationError: ValidationError

    public func isValid(value: T?) -> ValidationError? {
        if let str = value as? String {
            return (str.characters.count != 42) ? validationError : nil
        }
        return value != nil ? nil : validationError
    }
}
