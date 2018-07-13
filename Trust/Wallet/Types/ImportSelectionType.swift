// Copyright DApps Platform Inc. All rights reserved.

import Foundation

enum ImportSelectionType {
    case keystore
    case privateKey
    case mnemonic
    case address

    var title: String {
        switch self {
        case .keystore:
            return R.string.localizable.keystore()
        case .privateKey:
            return R.string.localizable.privateKey()
        case .mnemonic:
            return R.string.localizable.phrase()
        case .address:
            return R.string.localizable.address()
        }
    }

    init(title: String?) {
        switch title {
        case ImportSelectionType.privateKey.title?:
            self = .privateKey
        case ImportSelectionType.address.title?:
            self = .address
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
        case .address:
            return NSLocalizedString("import.watch.footer", value: "You can “watch” any public address without divulging your private key. This let’s you view balances and transactions, but not send transactions.", comment: "")
        }
    }
}
