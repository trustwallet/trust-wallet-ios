// Copyright SIX DAY LLC. All rights reserved.

import Foundation

class BrowserURLParser {

    private let defaultURL = "google.com"
    let searchURL = "https://www.google.com/search?q="
    let schemes = ["http", "https"]

    init() {

    }

    func url(from string: String) -> URL? {
        let urlString = appendScheme(for: string)
        let component = NSURLComponents(string: urlString)
        guard let componentURL = component?.url, let _ = component?.host  else {
            return searchURL(for: string)
        }
        return componentURL
    }

    func appendScheme(for string: String) -> String {
        let values = schemes.filter { string.hasPrefix($0) }
        return values.isEmpty ? "http://" + string : string
    }

    func searchURL(for query: String) -> URL? {
        return URL(string: searchURL + query)!
    }
}
