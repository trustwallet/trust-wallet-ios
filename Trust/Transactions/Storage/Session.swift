// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustCore

enum RefreshType {
    case balance
    case ethBalance
}

class WalletSession {
    let account: WalletInfo
    let balanceCoordinator: BalanceCoordinator
    let config: Config
    let chainState: ChainState
    var balance: Balance? {
        return balanceCoordinator.balance
    }

    var sessionID: String {
        return "\(account.address.description.lowercased())-\(config.chainID)"
    }

    var balanceViewModel: Subscribable<BalanceBaseViewModel> = Subscribable(nil)
    var nonceProvider: NonceProvider

    init(
        account: WalletInfo,
        config: Config,
        balanceCoordinator: BalanceCoordinator,
        nonceProvider: NonceProvider
    ) {
        self.account = account
        self.config = config
        self.chainState = ChainState(config: config)
        self.nonceProvider = nonceProvider
        self.balanceCoordinator = balanceCoordinator
        self.chainState.start()
        self.balanceCoordinator.delegate = self
    }

    func refresh() {
        balanceCoordinator.refresh()
    }

    func stop() {
        chainState.stop()
    }
}

extension WalletSession: BalanceCoordinatorDelegate {
    func didUpdate(viewModel: BalanceViewModel) {
        balanceViewModel.value = viewModel
    }
}
