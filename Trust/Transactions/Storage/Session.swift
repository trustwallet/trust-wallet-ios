// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum RefreshType {
    case balance
}

class WalletSession {

    let account: Account
    let web3: Web3Swift
    let config: Config
    let chainState: ChainState

    private lazy var balanceCoordinator: BalanceCoordinator = {
        return BalanceCoordinator(session: self)
    }()

    var balanceViewModel: Subscribable<BalanceViewModel> = Subscribable(nil)

    init(
        account: Account,
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
