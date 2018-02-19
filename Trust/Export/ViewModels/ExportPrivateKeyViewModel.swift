// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore

struct ExportPrivateKeyViewModel {

    let config: Config
    let keystore: Keystore
    let accout: Account

    init(
        config: Config = Config(),
        keystore: Keystore,
        accout: Account
    ) {
        self.config = config
        self.keystore = keystore
        self.accout = accout
    }

    var headlineText: String {
        return NSLocalizedString("export.warning.private.key", value: "Export at your own risk!", comment: "")
    }

    var privateKey: String {
        do {
            let key = try keystore.exportPrivateKey(account: accout).dematerialize()
            return key.hexString
        } catch {
            return NSLocalizedString("export.noKPrivateKey.label.title", value: "No Private Key for wallet", comment: "")
        }
    }

    var revealButtonTitle: String {
        return NSLocalizedString("export.reveal.btn.title", value: "Hold to Reveal", comment: "")
    }

    var warningText: String {
        return NSLocalizedString("export.warningTwo.private.key", value: "If anyone gets ahold of your private key, they can take your entire wallet!", comment: "")
    }

    var backgroundColor: UIColor {
        return .white
    }
}
