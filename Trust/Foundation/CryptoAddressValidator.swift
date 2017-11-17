// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum AddressValidatorType {
    case ethereum
}

struct CryptoAddressValidator {
    static func isValidAddress(_ value: String?, type: AddressValidatorType = .ethereum) -> Bool {
        guard value?.count == 42 else {
            return false
        }
        return true
    }
}
