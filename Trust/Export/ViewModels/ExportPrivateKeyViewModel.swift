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
        return String(format: NSLocalizedString("export.your.private.key", value: "Your Private Key.", comment: ""))
    }

    var privateKey: String {
        do {
            let key = try keystore.exportPrivateKey(account: accout).dematerialize()
            return key.hexString
        } catch {
            return String(format: NSLocalizedString("export.noKPrivateKey.label.title", value: "No Private Key for wallet", comment: ""))
        }
    }

    var copyTitlte: String {
        return String(format: NSLocalizedString("export.copy.btn.title", value: "Copy Private Key", comment: ""))
    }

    var copied: String {
        return String(format: NSLocalizedString("export.copied.private.key.text", value: "Private Key Copied", comment: ""))
    }

    var backgroundColor: UIColor {
        return .white
    }
}
