// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustKeystore

struct ExportPhraseViewModel {

    let keystore: Keystore
    let account: Account

    init(
        keystore: Keystore,
        account: Account
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
