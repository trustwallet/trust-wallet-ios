// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct PassphraseViewModel {

    var title: String {
        return NSLocalizedString(
            "recoveryPhrase.navigation.title",
            value: "Recovery Phrase",
            comment: ""
        )
    }

    var backgroundColor: UIColor {
        return .white
    }

    var rememberPassphraseText: String {
        return NSLocalizedString(
            "passphrase.remember.label.title",
            value: "Write this down, and keep it private and secure. You won't be able to restore your wallet if you lose this!",
            comment: ""
        )
    }

    var phraseFont: UIFont {
        return UIFont.systemFont(ofSize: 16, weight: .medium)
    }
}
