// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustKeystore

struct TrustRequestFormatter {
    static func toAddresses(from accounts: [Account]) -> [String: [String]] {
        var dict: [String: [String]] = [:]
        for account in accounts {
            guard let coin = account.coin else { break }
            dict["\(coin.coinType)"] = [account.address.description]
        }
        return dict
    }

    static func networks(from accounts: [Account]) -> [Int] {
        return accounts.compactMap { $0.coin?.coinType }
    }
}
