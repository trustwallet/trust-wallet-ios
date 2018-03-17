// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import APIKit
import JSONRPCKit
import Result
import BigInt
import RealmSwift

protocol BalanceCoordinatorDelegate: class {
    func didUpdate(viewModel: BalanceViewModel)
}

class BalanceCoordinator {
    let account: Wallet
    let storage: TokensDataStore
    let config: Config
    var balance: Balance?
    var currencyRate: CurrencyRate?
    weak var delegate: BalanceCoordinatorDelegate?
    var ethTokenObservation: NotificationToken?
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
        self.config = config
        self.storage = storage
        balanceObservation()
    }
    func refresh() {
        balanceObservation()
    }
    private func balanceObservation() {
        guard let token = storage.enabledObject.first(where: { $0.name == config.server.name }) else {
            return
        }
        updateBalance(for: token, with: nil)
        ethTokenObservation = token.observe {[weak self] change in
            switch change {
            case .change:
                self?.updateBalance(for: token, with: BigInt(token.value))
            case .error, .deleted:
                break
            }
        }
    }
    private func update() {
        delegate?.didUpdate(viewModel: viewModel)
    }
    private func updateBalance(for token: TokenObject, with value: BigInt?) {
        let ticker = self.storage.coinTicker(for: token)
        self.balance = Balance(value: value ?? token.valueBigInt)
        self.currencyRate = ticker?.rate()
        self.update()
    }
}
