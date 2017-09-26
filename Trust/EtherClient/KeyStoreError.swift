// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum KeyStoreError: LocalizedError {
    case failedToDeleteAccount
    case failedToDecryptKey
    case failedToImport
    case failedToSignTransaction

    var errorDescription: String? {
        switch self {
        case .failedToDeleteAccount:
            return "Failed to delete account"
        case .failedToDecryptKey:
            return "Could not decrypt key with given passphrase"
        case .failedToImport:
            return "Failed to import keystore"
        case .failedToSignTransaction:
            return "Failed to sign transaction"
        }
    }
}
