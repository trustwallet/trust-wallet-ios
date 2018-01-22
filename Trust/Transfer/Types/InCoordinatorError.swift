// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum InCoordinatorError: LocalizedError {
    case onlyWatchAccount

    var errorDescription: String? {
        return NSLocalizedString(
            "InCoordinatorError.onlyWatchAccount",
            value: "This wallet could be only used for watching. Import Private Key/Keystore to sign transactions",
            comment: ""
        )
    }
}
