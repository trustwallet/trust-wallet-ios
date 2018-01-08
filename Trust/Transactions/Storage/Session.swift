// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore

enum RefreshType {
    case balance
}

class WalletSession {
    let account: Wallet
    let web3: Web3Swift
    let config: Config
    let chainState: ChainState
    var balance: Balance? {
        return balanceCoordinator.balance
    }

    private lazy var balanceCoordinator: BalanceCoordinator = {
        return BalanceCoordinator(session: self)
    }()

    var balanceViewModel: Subscribable<BalanceBaseViewModel> = Subscribable(nil)

    init(
        account: Wallet,
        config: Config
    ) {
        self.account = account
        self.config = config
        self.web3 = Web3Swift(url: config.rpcURL)
        self.chainState = ChainState(config: config)
        self.web3.start()
        self.balanceCoordinator.start()
        self.balanceCoordinator.delegate = self

        self.chainState.start()
    }

    func refresh(_ type: RefreshType) {
        switch type {
        case .balance:
            balanceCoordinator.fetch()
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
