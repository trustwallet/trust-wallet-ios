// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct Rate: Codable {
    let code: String
    let price: Double
    let contract: String
}

struct CurrencyRate: Codable {
    let rates: [Rate]
}
