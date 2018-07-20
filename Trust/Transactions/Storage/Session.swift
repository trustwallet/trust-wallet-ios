// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore
import RealmSwift

enum RefreshType {
    case balance
    case ethBalance
}

final class WalletSession {
    let account: WalletInfo
    lazy var balanceCoordinator: BalanceCoordinator = {
        return BalanceCoordinator(account: account, config: config, storage: tokensStorage, server: RPCServer.main)
    }()
    let config: Config
    var balance: Balance? {
        return balanceCoordinator.balance
    }
    let realm: Realm
    let sharedRealm: Realm

    var sessionID: String {
        return "\(account.address.description.lowercased())-\(account.server.chainID)"
    }

    var balanceViewModel: Subscribable<BalanceBaseViewModel> = Subscribable(nil)

    // storage

    lazy var walletStorage: WalletStorage = {
        return WalletStorage(realm: sharedRealm)
    }()
    lazy var tokensStorage: TokensDataStore = {
        return TokensDataStore(realm: realm, account: account)
    }()
    lazy var transactionsStorage: TransactionsStorage = {
        return TransactionsStorage(
            realm: realm,
            account: account
        )
    }()

    init(
        account: WalletInfo,
        realm: Realm,
        sharedRealm: Realm,
        config: Config
    ) {
        self.account = account
        self.realm = realm
        self.sharedRealm = sharedRealm
        self.config = config
    }

    func refresh() {
        balanceCoordinator.refresh()
    }
}

extension WalletSession: BalanceCoordinatorDelegate {
    func didUpdate(viewModel: BalanceViewModel) {
        balanceViewModel.value = viewModel
    }
}
