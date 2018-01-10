// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct Rate {
    let code: String
    let price: Double
    let contract: String
}

struct CurrencyRate {
    let currency: String
    let rates: [Rate]
}
