// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

struct PassphraseViewModel {

    var title: String {
        return R.string.localizable.backupPhrase()
    }

    var backgroundColor: UIColor {
        return .white
    }

    var phraseFont: UIFont {
        return UIFont.systemFont(ofSize: 16, weight: .medium)
    }
}
