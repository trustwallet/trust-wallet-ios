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
    var transactionCoordinator: TransactionCoordinator? {
        return self.coordinators.flatMap { $0 as? TransactionCoordinator }.first
    }

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
        checkDevice()
    }

    func showTabBar(for account: Account) {
        let session = WalletSession(
            account: account,
            config: config
        )
        MigrationInitializer(account: account, chainID: config.chainID).perform()

        let inCoordinatorViewModel = InCoordinatorViewModel(config: config)
        let transactionCoordinator = TransactionCoordinator(
            session: session,
            storage: TransactionsStorage(
                configuration: RealmConfiguration.configuration(for: account, chainID: session.config.chainID)
            ),
            keystore: keystore
        )
        transactionCoordinator.rootViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("transactions.tabbar.item.title", value: "Transactions", comment: ""), image: R.image.feed(), selectedImage: nil)
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
                session: session,
                keystore: keystore
            )
            tokenCoordinator.rootViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("tokens.tabbar.item.title", value: "Tokens", comment: ""), image: R.image.coins(), selectedImage: nil)
            tokenCoordinator.start()
            addCoordinator(tokenCoordinator)
            tabBarController.viewControllers?.append(tokenCoordinator.navigationController)
        }

        if inCoordinatorViewModel.exchangeAvailable {
            let exchangeCoordinator = ExchangeCoordinator(session: session, keystore: keystore)
            exchangeCoordinator.rootViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("exchange.tabbar.item.title", value: "Exchange", comment: ""), image: R.image.exchange(), selectedImage: nil)
            exchangeCoordinator.start()
            addCoordinator(exchangeCoordinator)
            tabBarController.viewControllers?.append(exchangeCoordinator.navigationController)
        }

        let settingsCoordinator = SettingsCoordinator(keystore: keystore)
        settingsCoordinator.rootViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("settings.navigation.title", value: "Settings", comment: ""),
            image: R.image.settings_icon(),
            selectedImage: nil
        )
        settingsCoordinator.delegate = self
        settingsCoordinator.start()
        addCoordinator(settingsCoordinator)
        tabBarController.viewControllers?.append(settingsCoordinator.navigationController)

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

        guard let transactionCoordinator = transactionCoordinator else { return }
        restart(for: account, in: transactionCoordinator)
    }

    func restart(for account: Account, in coordinator: TransactionCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        coordinator.stop()
        removeCoordinator(coordinator)
        showTabBar(for: account)
    }

    func checkDevice() {
        let deviceChecker = CheckDeviceCoordinator(
            navigationController: navigationController,
            jailbreakChecker: DeviceChecker()
        )

        deviceChecker.start()

        addCoordinator(deviceChecker)
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

extension InCoordinator: SettingsCoordinatorDelegate {
    func didUpdate(action: SettingsAction, in coordinator: SettingsCoordinator) {
        switch action {
        case .RPCServer:
            removeCoordinator(coordinator)
            guard let transactionCoordinator = transactionCoordinator else { return }
            restart(for: account, in: transactionCoordinator)
        case .pushNotifications:
            break
        case .donate(let address):
            guard let transactionCoordinator = transactionCoordinator else { return }
            transactionCoordinator.showPaymentFlow(for: .send(type: .ether(destination: address)))
        }
    }

    func didCancel(in coordinator: SettingsCoordinator) {
        removeCoordinator(coordinator)
        coordinator.navigationController.dismiss(animated: true, completion: nil)
    }
}
