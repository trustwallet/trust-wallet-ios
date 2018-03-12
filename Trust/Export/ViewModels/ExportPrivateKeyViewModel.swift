// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore

struct ExportPrivateKeyViewModel {

    let keystore: Keystore
    let account: Account

    init(
        keystore: Keystore,
        account: Account
    ) {
        self.keystore = keystore
        self.account = account
    }

    var headlineText: String {
        return NSLocalizedString("export.warning.private.key", value: "Export at your own risk!", comment: "")
    }

    var privateKey: String {
        do {
            let key = try keystore.exportPrivateKey(account: account).dematerialize()
            return key.hexString
        } catch {
            return NSLocalizedString("export.noKPrivateKey.label.title", value: "No Private Key for wallet", comment: "")
        }
    }

    var revealButtonTitle: String {
        return NSLocalizedString("export.reveal.button.title", value: "Hold to Reveal", comment: "")
    }

    var warningText: String {
        return NSLocalizedString("export.warningTwo.private.key", value: "Anyone with your Private Key will have FULL access to your wallet!", comment: "")
    }

    var backgroundColor: UIColor {
        return .white
    }
}
