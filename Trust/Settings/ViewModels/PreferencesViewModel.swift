// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct PreferencesViewModel {

    var title: String {
        return NSLocalizedString("settings.preferences.title", value: "Preferences", comment: "")
    }

    var showTokensTabTitle: String {
        return NSLocalizedString("settings.preferences.button.title", value: "Show Tokens on Launch", comment: "")
    }

    var showTokensTabOnStart: Bool {
        return true
    }
}
