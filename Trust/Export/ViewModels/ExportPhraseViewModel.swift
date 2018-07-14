// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustKeystore

struct ExportPhraseViewModel {

    let keystore: Keystore
    let account: Wallet

    init(
        keystore: Keystore,
        account: Wallet
    ) {
        self.keystore = keystore
        self.account = account
    }

    var title: String {
        return R.string.localizable.backupPhrase()
    }

    var backgroundColor: UIColor {
        return .white
    }
}
