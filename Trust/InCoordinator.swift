// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol InCoordinatorDelegate: class {
    func didCancel(in coordinator: InCoordinator)
    func didUpdateAccounts(in coordinator: InCoordinator)
}

class InCoordinator: Coordinator {

    let navigationController: UINavigationController
    var coordinators: [Coordinator] = []
    let account: Account
    var keystore: Keystore
    let config = Config()
    weak var delegate: InCoordinatorDelegate?

    init(
        navigationController: UINavigationController = NavigationController(),
        account: Account,
        keystore: Keystore
    ) {
        self.navigationController = navigationController
        self.account = account
        self.keystore = keystore
    }

    func start() {
        showTransactions(for: account)
    }

    func showTransactions(for account: Account) {
        let session = WalletSession(
            account: account
        )

        let coordinator = TransactionCoordinator(
            session: session,
            rootNavigationController: navigationController,
            storage: TransactionsStorage(
                current: account,
                chainID: config.chainID
            )
        )
        coordinator.delegate = self
        navigationController.viewControllers = [
            coordinator.rootViewController,
        ]
        navigationController.setNavigationBarHidden(false, animated: false)
        addCoordinator(coordinator)

        keystore.recentlyUsedAccount = account
    }
}

extension InCoordinator: TransactionCoordinatorDelegate {
    func didCancel(in coordinator: TransactionCoordinator) {
        delegate?.didCancel(in: self)
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        coordinator.stop()
        removeCoordinator(coordinator)
    }

    func didRestart(with account: Account, in coordinator: TransactionCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        coordinator.stop()
        removeCoordinator(coordinator)
        showTransactions(for: account)
    }

    func didUpdateAccounts(in coordinator: TransactionCoordinator) {
        delegate?.didUpdateAccounts(in: self)
    }
}
