// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct PreferencesViewModel {

    var title: String {
        return NSLocalizedString("settings.preferences.title", value: "Preferences", comment: "")
    }

    var searchEngineTitle: String {
        return NSLocalizedString("settings.browser.searchEngine.title", value: "Search Engine", comment: "")
    }

    var searchEngines: [SearchEngine] {
        return [.google, .duckDuckGo]
    }
}
