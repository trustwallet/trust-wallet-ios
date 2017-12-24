// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

struct CoinTicker: Codable {
    let name: String
    let symbol: String
    let price: String
    let percent_change_24h: String
}
