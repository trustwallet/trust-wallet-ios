// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum ImportSelectionType {
    case keystore
    case privateKey
    case mnemonic
    case watch

    var title: String {
        switch self {
        case .keystore:
            return "Keystore"
        case .privateKey:
            return "Private Key"
        case .mnemonic:
            return "Mnemonic"
        case .watch:
            return "Watch"
        }
    }

    init(title: String?) {
        switch title {
        case ImportSelectionType.privateKey.title?:
            self = .privateKey
        case ImportSelectionType.watch.title?:
            self = .watch
        case ImportSelectionType.mnemonic.title?:
            self = .mnemonic
        default:
            self = .keystore
        }
    }
}
