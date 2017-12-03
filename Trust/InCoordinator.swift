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
    var config: Config
    weak var delegate: InCoordinatorDelegate?

    init(
        navigationController: UINavigationController = NavigationController(),
        account: Account,
        keystore: Keystore,
        config: Config = Config()
    ) {
        self.navigationController = navigationController
        self.account = account
        self.keystore = keystore
        self.config = config
    }

    func start() {
        showTabBar(for: account)
    }

    func showTabBar(for account: Account) {
        let session = WalletSession(
            account: account,
            config: config
        )
        let inCoordinatorViewModel = InCoordinatorViewModel(config: config)
        let transactionCoordinator = TransactionCoordinator(
            session: session,
            storage: TransactionsStorage(
                current: account,
                chainID: config.chainID
            ),
            keystore: keystore
        )
        transactionCoordinator.rootViewController.tabBarItem = UITabBarItem(title: "Transactions", image: R.image.feed(), selectedImage: nil)
        transactionCoordinator.delegate = self
        transactionCoordinator.start()
        addCoordinator(transactionCoordinator)

        let tabBarController = TabBarController()
        tabBarController.viewControllers = [
            transactionCoordinator.navigationController,
        ]
        tabBarController.tabBar.isTranslucent = false
        tabBarController.didShake = { [weak self] in
            if inCoordinatorViewModel.canActivateDebugMode {
                self?.activateDebug()
            }
        }

        if inCoordinatorViewModel.tokensAvailable {
            let tokenCoordinator = TokensCoordinator(
                session: session
            )
            tokenCoordinator.rootViewController.tabBarItem = UITabBarItem(title: "Tokens", image: R.image.coins(), selectedImage: nil)
            tokenCoordinator.start()
            addCoordinator(tokenCoordinator)
            tabBarController.viewControllers?.append(tokenCoordinator.navigationController)
        }

        if inCoordinatorViewModel.exchangeAvailable {
            let exchangeCoordinator = ExchangeCoordinator(session: session)
            exchangeCoordinator.rootViewController.tabBarItem = UITabBarItem(title: "Exchange", image: R.image.exchange(), selectedImage: nil)
            exchangeCoordinator.start()
            addCoordinator(exchangeCoordinator)
            tabBarController.viewControllers?.append(exchangeCoordinator.navigationController)
        }

        navigationController.setViewControllers(
            [tabBarController],
            animated: false
        )
        navigationController.setNavigationBarHidden(true, animated: false)
        addCoordinator(transactionCoordinator)

        keystore.recentlyUsedAccount = account
    }

    @objc func activateDebug() {
        config.isDebugEnabled = !config.isDebugEnabled

        let coordinators: [TransactionCoordinator] = self.coordinators.flatMap { $0 as? TransactionCoordinator }
        if let coordinator = coordinators.first {
            restart(for: account, in: coordinator)
        }
    }

    func restart(for account: Account, in coordinator: TransactionCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        coordinator.stop()
        removeCoordinator(coordinator)
        showTabBar(for: account)
    }
}

extension InCoordinator: TransactionCoordinatorDelegate {
    func didCancel(in coordinator: TransactionCoordinator) {
        delegate?.didCancel(in: self)
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        coordinator.stop()
        removeAllCoordinators()
    }

    func didRestart(with account: Account, in coordinator: TransactionCoordinator) {
        restart(for: account, in: coordinator)
    }

    func didUpdateAccounts(in coordinator: TransactionCoordinator) {
        delegate?.didUpdateAccounts(in: self)
    }
}
