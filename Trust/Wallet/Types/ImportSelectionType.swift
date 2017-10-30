// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum ImportSelectionType {
    case keystore
    case privateKey

    var title: String {
        switch self {
        case .keystore:
            return "Keystore"
        case .privateKey:
            return "Private Key"
        }
    }

    init(title: String?) {
        switch title {
        case ImportSelectionType.privateKey.title?:
            self = .privateKey
        default:
            self = .keystore
        }
    }
}
