// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import APIKit
import JSONRPCKit
import Result
import BigInt
import RealmSwift

final class BalanceCoordinator {
    let account: WalletInfo
    let storage: TokensDataStore
    let config: Config
    var currencyRate: CurrencyRate {
        return CurrencyRate(
            rates: storage.tickers().map { Rate(price: Double($0.price) ?? 0, contract: $0.contract) }
        )
    }
    let server: RPCServer
    init(
        account: WalletInfo,
        config: Config,
        storage: TokensDataStore,
        server: RPCServer
    ) {
        self.account = account
        self.config = config
        self.storage = storage
        self.server = server
    }

    func balance(for token: TokenObject) -> Balance? {
        return Balance(value: token.valueBigInt)
    }
}
