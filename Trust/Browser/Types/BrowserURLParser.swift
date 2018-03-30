// Copyright SIX DAY LLC. All rights reserved.

import Foundation

class BrowserURLParser {
    let urlRegEx = try! NSRegularExpression(pattern: "^(http(s)?://)?[a-z0-9-_]+(\\.[a-z0-9-_]+)+(/)?", options: .caseInsensitive)
    let validSchemes = ["http", "https"]
    let searchHost: String

    init(searchHost: String = "www.google.com") {
        self.searchHost = searchHost
    }

    /// Determines if a string is an address or a search query and returns the appropriate URL.
    func url(from string: String) -> URL? {
        let range = NSRange(string.startIndex ..< string.endIndex, in: string)
        if urlRegEx.firstMatch(in: string, options: .anchored, range: range) != nil {
            if !validSchemes.contains(where: { string.hasPrefix("\($0)://") }) {
                return URL(string: "http://" + string)
            } else {
                return URL(string: string)
            }
        }

        return buildSearchURL(for: string)
    }

    /// Builds a search URL from a seach query string.
    func buildSearchURL(for query: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = searchHost
        components.path = "/search"
        components.queryItems = [URLQueryItem(name: "q", value: query)]
        return try! components.asURL()
    }
}
