// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum KeyStoreError: LocalizedError {
    case failedToDeleteAccount
    case failedToDecryptKey
    case failedToImport(Error)
    case failedToSignTransaction
    case failedToUpdatePassword

    var errorDescription: String? {
        switch self {
        case .failedToDeleteAccount:
            return "Failed to delete account"
        case .failedToDecryptKey:
            return "Could not decrypt key with given passphrase"
        case .failedToImport(let error):
            return error.localizedDescription
        case .failedToSignTransaction:
            return "Failed to sign transaction"
        case .failedToUpdatePassword:
            return "Failed to update password"
        }
    }
}
