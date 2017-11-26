// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum AddressValidatorType {
    case ethereum

    var length: Int {
        switch self {
        case .ethereum: return 42
        }
    }
}

struct CryptoAddressValidator {
    static func isValidAddress(_ value: String?, type: AddressValidatorType = .ethereum) -> Bool {
        guard value?.count == 42 else {
            return false
        }
        return true
    }
}
