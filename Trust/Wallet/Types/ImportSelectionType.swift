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
            return NSLocalizedString("Keystore", value: "Keystore", comment: "")
        case .privateKey:
            return NSLocalizedString("Private Key", value: "Private Key", comment: "")
        case .mnemonic:
            return NSLocalizedString("Mnemonic", value: "Mnemonic", comment: "")
        case .watch:
            return NSLocalizedString("Watch", value: "Watch", comment: "")
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

    var footerTitle: String {
        switch self {
        case .keystore:
            return NSLocalizedString("import.keystore.footer", value: "Several lines of text beginning with “{...}” plus the password you used to encrypt it", comment: "")
        case .privateKey:
            return NSLocalizedString("import.privateKey.footer", value: "Typically 64 alphanumeric characters", comment: "")
        case .mnemonic:
            return NSLocalizedString("import.mnemonic.footer", value: "Typically 12 (sometimes 24) words separated by single spaces", comment: "")
        case .watch:
            return NSLocalizedString("import.watch.footer", value: "You can “watch” any public address without divulging your private key. This let’s you view balances and transactions, but not send transactions.", comment: "")
        }
    }
}
