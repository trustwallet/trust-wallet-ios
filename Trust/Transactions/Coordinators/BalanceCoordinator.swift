// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import APIKit
import JSONRPCKit
import Result
import BigInt

protocol BalanceCoordinatorDelegate: class {
    func didUpdate(viewModel: BalanceViewModel)
}

class BalanceCoordinator {
    let account: Wallet
    let storage: TokensDataStore
    var balance: Balance?
    var currencyRate: CurrencyRate?
    weak var delegate: BalanceCoordinatorDelegate?
    var viewModel: BalanceViewModel {
        return BalanceViewModel(
            balance: balance,
            rate: currencyRate
        )
    }
    init(
        account: Wallet,
        config: Config,
        storage: TokensDataStore
    ) {
        self.account = account
        self.storage = storage
        self.storage.refreshBalance()

        let etherToken = TokensDataStore.etherToken(for: config)

        storage.tokensModel.subscribe {[weak self] tokensModel in
            guard let tokens = tokensModel, let eth = tokens.first(where: { $0 == etherToken }) else {
                return
            }
            var ticker = storage.coinTicker(for: eth)
            self?.balance = Balance(value: BigInt(eth.value, radix: 10) ?? BigInt(0))
            self?.currencyRate = ticker?.rate
            self?.update()
        }
    }
    func refresh() {
        self.storage.refreshBalance()
    }
    func update() {
        delegate?.didUpdate(viewModel: viewModel)
    }
}
