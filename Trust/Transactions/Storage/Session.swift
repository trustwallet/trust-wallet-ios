// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore

enum RefreshType {
    case balance
}

class WalletSession {
    let account: Wallet
    let web3: Web3Swift
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

    init(
        account: Wallet,
        config: Config,
        web3: Web3Swift,
        balanceCoordinator: BalanceCoordinator
    ) {
        self.account = account
        self.config = config
        self.web3 = web3
        self.chainState = ChainState(config: config)
        self.balanceCoordinator = balanceCoordinator
        self.balanceCoordinator.delegate = self

        self.chainState.start()
    }

    func refresh(_ type: RefreshType) {
        switch type {
        case .balance:
            balanceCoordinator.refresh()
        }
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
