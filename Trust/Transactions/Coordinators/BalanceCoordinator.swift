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
    var ethTokenObservation : NotificationToken?
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
    func balanceObservation() {
        guard let token = storage.enabledObject.first(where: { $0.name == config.server.name }) else {
            return
        }
        ethTokenObservation = token.observe {[weak self] change in
            switch change {
            case .change(let properties):
                for property in properties {
                    guard property.name == "value", let property = property.newValue as? String else {
                        return
                    }
                    var ticker = self?.storage.coinTicker(for: token)
                    self?.balance = Balance(value: BigInt(property) ?? BigInt(0))
                    self?.currencyRate = ticker?.rate
                    self?.update()
                }
            case .error(let error):
                print("An error occurred with \(token.name): \(error)")
            case .deleted:
                print("The \(token.name) object was deleted.")
            }
        }
    }
    func update() {
        delegate?.didUpdate(viewModel: viewModel)
    }
}
