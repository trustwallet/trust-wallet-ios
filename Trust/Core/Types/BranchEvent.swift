// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustCore

enum BranchEventName: String {
    case openURL
    case newToken
}

enum BranchEvent {
    case openURL(URL)
    case newToken(Address)

    var params: [String: String] {
        switch self {
        case .openURL(let url):
            return [
                "url": url.absoluteString,
                "event": BranchEventName.openURL.rawValue,
            ]
        case .newToken(let address):
            return [
                "contract": address.eip55String,
                "event": BranchEventName.newToken.rawValue,
            ]
        }
    }
}

extension BranchEvent: Equatable {
    static func == (lhs: BranchEvent, rhs: BranchEvent) -> Bool {
        switch (lhs, rhs) {
        case (let .openURL(lhs), let .openURL(rhs)):
            return lhs == rhs
        case (let .newToken(lhs), let .newToken(rhs)):
            return lhs == rhs
        case (_, .openURL),
             (_, .newToken):
            return false
        }
    }
}
