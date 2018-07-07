// Copyright DApps Platform Inc. All rights reserved.

import Foundation

struct BrowserConfigurationViewModel {

    var title: String {
        return NSLocalizedString("settings.browser.title", value: "DApp Browser", comment: "")
    }

    var searchEngineTitle: String {
        return NSLocalizedString("settings.browser.searchEngine.title", value: "Search Engine", comment: "")
    }

    var searchEngines: [SearchEngine] {
        return [.google, .duckDuckGo]
    }

    var clearBrowserCacheTitle: String {
        return NSLocalizedString("settings.browser.clearCache.title", value: "Clear Browser Cache", comment: "")
    }

    var clearBrowserCacheConfirmTitle: String {
        return NSLocalizedString("settings.browser.clearCache.alert.title", value: "Clear Browsing Data?", comment: "")
    }

    var clearBrowserCacheConfirmMessage: String {
        return NSLocalizedString("settings.browser.clearCache.alert.message", value: "This will clear cache, cookies, and other browsing data.", comment: "")
    }
}
