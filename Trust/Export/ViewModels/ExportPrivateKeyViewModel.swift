// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustKeystore

struct ExportPrivateKeyViewModel {

    let privateKey: Data

    init(
        privateKey: Data
    ) {
        self.privateKey = privateKey
    }

    var headlineText: String {
        return NSLocalizedString("export.warning.private.key", value: "Export at your own risk!", comment: "")
    }

    var privateKeyString: String {
        return privateKey.hexString
    }

    var warningText: String {
        return NSLocalizedString("export.warningTwo.private.key", value: "Anyone with your Private Key will have FULL access to your wallet!", comment: "")
    }

    var backgroundColor: UIColor {
        return .white
    }
}
