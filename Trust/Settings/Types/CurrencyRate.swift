// Copyright DApps Platform Inc. All rights reserved.

import Foundation

struct Rate: Codable {
    let price: Double
    let contract: String
}

struct CurrencyRate: Codable {
    let rates: [String: Double]
}
