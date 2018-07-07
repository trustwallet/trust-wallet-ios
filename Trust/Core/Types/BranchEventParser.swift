// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore

struct BranchEventParser {

    static func from(params: [String: AnyObject]) -> BranchEvent? {
        guard let event = params["event"] as? String else {
            return .none
        }

        switch event {
        case BranchEventName.openURL.rawValue:
            guard let urlString = params["url"] as? String, let url = URL(string: urlString) else { return .none }
            return BranchEvent.openURL(url)
        case BranchEventName.newToken.rawValue:
            guard let contract = params["contract"] as? String, let address = Address(string: contract) else { return .none }
            return BranchEvent.newToken(address)
        default:
            return .none
        }
    }
}
