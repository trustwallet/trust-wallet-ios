// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum RefreshType {
    case balance
}

class WalletSession {

    let account: Account

    private lazy var balanceCoordinator: BalanceCoordinator = {
        return BalanceCoordinator(account: self.account)
    }()

    var balanceViewModel: Subscribable<BalanceViewModel> = Subscribable(nil)

    init(account: Account) {
        self.account = account
        self.balanceCoordinator.start()
        self.balanceCoordinator.delegate = self
    }

    func refresh(_ type: RefreshType) {
        switch type {
        case .balance:
            balanceCoordinator.fetch()
        }
    }

    func stop() {

    }
}

extension WalletSession: BalanceCoordinatorDelegate {
    func didUpdate(viewModel: BalanceViewModel) {
        balanceViewModel.value = viewModel
    }
}
