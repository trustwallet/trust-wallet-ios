// Copyright DApps Platform Inc. All rights reserved.

import Foundation

enum AddressValidatorType {
    case ethereum

    var addressLength: Int {
        switch self {
        case .ethereum: return 42
        }
    }
}

struct CryptoAddressValidator {
    static func isValidAddress(_ value: String?, type: AddressValidatorType = .ethereum) -> Bool {
        return value?.range(of: "^0x[a-fA-F0-9]{40}$", options: .regularExpression) != nil
    }
}
