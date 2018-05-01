// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum BranchEventName: String {
    case openURL
}

enum BranchEvent {
    case openURL(URL)

    var name: String {
        return "openURL"
    }

    var params: [String: String] {
        switch self {
        case .openURL(let url):
            return [
                "url": url.absoluteString,
                "event": BranchEventName.openURL.rawValue
            ]
        }
    }
}

extension BranchEvent: Equatable {
    static func == (lhs: BranchEvent, rhs: BranchEvent) -> Bool {
        switch (lhs, rhs) {
        case (let .openURL(lhs), let .openURL(rhs)):
            return lhs == rhs
//        case (_, .openURL):
//            return false
        }
    }
}
