// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore

extension DecryptError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidPassword:
            return "Invalid Password"
        case .invalidCipher:
            return "Invalid Cipher"
        case .unsupportedCipher:
            return "Unsupported Cipher"
        case .unsupportedKDF:
            return "Unsupported KDF"
        }
    }
}
