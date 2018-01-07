// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum ImportSelectionType {
    case keystore
    case privateKey
    case watch

    var title: String {
        switch self {
        case .keystore:
            return "Keystore"
        case .privateKey:
            return "Private Key"
        case .watch:
            return "Watch"
        }
    }

    init(title: String?) {
        switch title {
        case ImportSelectionType.privateKey.title?:
            self = .privateKey
        case ImportSelectionType.keystore.title?:
            self = .keystore
        case ImportSelectionType.watch.title?:
            self = .watch
        default:
            self = .keystore
        }
    }
}
