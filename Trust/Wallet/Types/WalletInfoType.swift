// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore
import UIKit

enum WalletInfoType {
    case exportRecoveryPhrase(Account)
    case exportPrivateKey(Account)
    case exportKeystore(Account)

    var title: String {
        switch self {
        case .exportRecoveryPhrase:
            return NSLocalizedString("wallet.info.exportRecoveryPhrase", value: "Export Recovery phrase", comment: "")
        case .exportKeystore:
            return NSLocalizedString("wallets.backup.alertSheet.title", value: "Backup Keystore", comment: "")
        case .exportPrivateKey:
            return NSLocalizedString("wallets.export.alertSheet.title", value: "Export Private Key", comment: "")
        }
    }

    var image: UIImage? {
        switch self {
        case .exportRecoveryPhrase:
            return R.image.backup_warning()
        case .exportKeystore:
            return R.image.backup_warning()
        case .exportPrivateKey:
            return R.image.backup_warning()
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
        case (_, .exportRecoveryPhrase),
             (_, .exportKeystore),
             (_, .exportPrivateKey):
            return false
        }
    }
}
