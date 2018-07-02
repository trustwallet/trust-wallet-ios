// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum SearchEngine: Int {
    case google = 0
    case duckDuckGo

    static var `default`: SearchEngine {
        return .google
    }

    var title: String {
        switch self {
        case .google:
            return R.string.localizable.google()
        case .duckDuckGo:
            return R.string.localizable.duckDuckGo()
        }
    }

    var host: String {
        switch self {
        case .google:
            return "google.com"
        case .duckDuckGo:
            return "duckduckgo.com"
        }
    }

    func path(for query: String) -> String {
        switch self {
        case .google:
            return "/search"
        case .duckDuckGo:
            return "/\(query)"
        }
    }

    func queryItems(for query: String) -> [URLQueryItem] {
        switch self {
        case .google: return [URLQueryItem(name: "q", value: query)]
        case .duckDuckGo: return []
        }
    }
}
