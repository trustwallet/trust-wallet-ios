// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustKeystore
import UIKit
import TrustCore

enum WalletInfoType {
    case exportRecoveryPhrase(Wallet)
    case exportPrivateKey(Account)
    case exportKeystore(Account)
    case copyAddress(Address)

    var title: String {
        switch self {
        case .exportRecoveryPhrase:
            return NSLocalizedString("wallet.info.exportBackupPhrase", value: "Show Backup Phrase", comment: "")
        case .exportKeystore:
            return NSLocalizedString("wallets.backup.alertSheet.title", value: "Backup Keystore", comment: "")
        case .exportPrivateKey:
            return NSLocalizedString("wallets.export.alertSheet.title", value: "Export Private Key", comment: "")
        case .copyAddress:
            return R.string.localizable.copyAddress()
        }
    }

    var image: UIImage? {
        switch self {
        case .exportRecoveryPhrase:
            return R.image.mnemonic_backup_icon()
        case .exportKeystore:
            return R.image.keystore_backup_icon()
        case .exportPrivateKey:
            return R.image.private_key_icon()
        case .copyAddress:
            return R.image.copy_wallet_icon()
        }
    }
}

extension WalletInfoType: Equatable {
    static func == (lhs: WalletInfoType, rhs: WalletInfoType) -> Bool {
        switch (lhs, rhs) {
        case (let .exportRecoveryPhrase(lhs), let .exportRecoveryPhrase(rhs)):
            return lhs == rhs
        case (let .exportKeystore(lhs), let .exportKeystore(rhs)):
            return lhs == rhs
        case (let .exportPrivateKey(lhs), let .exportPrivateKey(rhs)):
            return lhs == rhs
        case (let .copyAddress(lhs), let .copyAddress(rhs)):
            return lhs.data == rhs.data
        case (_, .exportRecoveryPhrase),
             (_, .exportKeystore),
             (_, .exportPrivateKey),
             (_, .copyAddress):
            return false
        }
    }
}
