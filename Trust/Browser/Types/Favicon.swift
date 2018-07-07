// Copyright DApps Platform Inc. All rights reserved.

import Foundation

struct Favicon {
    static func get(for url: URL?) -> URL? {
        guard let host = url?.host else {
            return .none
        }
        return URL(string: "https://api.statvoo.com/favicon/?url=\(host)")
    }
}
