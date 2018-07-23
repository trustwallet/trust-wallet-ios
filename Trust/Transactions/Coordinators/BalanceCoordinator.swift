// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import APIKit
import JSONRPCKit
import Result
import BigInt
import RealmSwift

final class BalanceCoordinator {
    let storage: TokensDataStore
    var currencyRate: CurrencyRate {
        var rates: [String: Double] = [:]
        storage.tickers().forEach { ticker in
            rates[ticker.contract] = Double(ticker.price) ?? 0
        }
        return CurrencyRate(
            rates: rates
        )
    }
    init(
        storage: TokensDataStore
    ) {
        self.storage = storage
    }

    func balance(for token: TokenObject) -> Balance? {
        return Balance(value: token.valueBigInt)
    }
}
