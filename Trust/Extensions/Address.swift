// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore

extension Address {
    var address: String {
        return description
    }
}

enum AddressError: LocalizedError {
    case invalidAddress

    var errorDescription: String? {
        switch self {
        case .invalidAddress:
            return NSLocalizedString("send.error.invalidAddress", value: "Invalid Address", comment: "")
        }
    }
}
