// Copyright SIX DAY LLC. All rights reserved.

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
