// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import APIKit
import JSONRPCKit

protocol BalanceCoordinatorDelegate: class {
    func didUpdate(viewModel: BalanceViewModel)
}

class BalanceCoordinator {

    let exchangeRateCoordinator = ExchangeRateCoordinator()
    let account: Account

    weak var delegate: BalanceCoordinatorDelegate?

    var balance: Balance? {
        didSet { update() }
    }
    var currencyRate: CurrencyRate? {
        didSet { update() }
    }

    var viewModel: BalanceViewModel {
        return BalanceViewModel(
            balance: balance,
            rate: currencyRate
        )
    }

    init(account: Account) {
        self.account = account
    }

    func start() {
        exchangeRateCoordinator.delegate = self
        exchangeRateCoordinator.start()

        fetchBalance()
    }

    func fetch() {
        exchangeRateCoordinator.fetch()
        fetchBalance()
    }

    func fetchBalance() {
        let request = EtherServiceRequest(batch: BatchFactory().create(BalanceRequest(address: account.address.address)))
        Session.send(request) { [weak self] result in
            switch result {
            case .success(let balance):
                self?.balance = balance
            case .failure:
                break
            }
        }
    }

    func update() {
        delegate?.didUpdate(viewModel: viewModel)
    }
}

extension BalanceCoordinator: ExchangeRateCoordinatorDelegate {
    func didUpdate(rate: CurrencyRate, in coordinator: ExchangeRateCoordinator) {
        currencyRate = rate
    }
}
