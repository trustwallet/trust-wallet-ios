// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore
import UIKit

protocol InCoordinatorDelegate: class {
    func didCancel(in coordinator: InCoordinator)
    func didUpdateAccounts(in coordinator: InCoordinator)
}

enum InCoordinatorError: LocalizedError {
    case onlyWatchAccount

    var errorDescription: String? {
        return NSLocalizedString(
            "InCoordinatorError.onlyWatchAccount",
            value: "This wallet could be only used for watching. Import Private Key/Keystore to sign transactions",
            comment: ""
        )
    }
}

class InCoordinator: Coordinator {

    let navigationController: UINavigationController
    var coordinators: [Coordinator] = []
    let initialWallet: Wallet
    var keystore: Keystore
    var config: Config
    let appTracker: AppTracker
    weak var delegate: InCoordinatorDelegate?
    var transactionCoordinator: TransactionCoordinator? {
        return self.coordinators.flatMap { $0 as? TransactionCoordinator }.first
    }
    lazy var helpUsCoordinator: HelpUsCoordinator = {
        return HelpUsCoordinator(
            navigationController: navigationController,
            appTracker: appTracker
        )
    }()

    init(
        navigationController: UINavigationController = NavigationController(),
        wallet: Wallet,
        keystore: Keystore,
        config: Config = Config(),
        appTracker: AppTracker = AppTracker()
    ) {
        self.navigationController = navigationController
        self.initialWallet = wallet
        self.keystore = keystore
        self.config = config
        self.appTracker = appTracker
    }

    func start() {
        showTabBar(for: initialWallet)
        checkDevice()

        helpUsCoordinator.start()
        addCoordinator(helpUsCoordinator)
    }

    func showTabBar(for account: Wallet) {
        let session = WalletSession(
            account: account,
            config: config
        )
        
        MigrationInitializer(account: account, chainID: config.chainID).perform()
        
        let tokensStorage = TokensDataStore(
            session: session,
            configuration: RealmConfiguration.configuration(for: session.account, chainID: session.config.chainID)
        )

        let transactionsStorage = TransactionsStorage(
            configuration: RealmConfiguration.configuration(for: account, chainID: session.config.chainID)
        )
        let inCoordinatorViewModel = InCoordinatorViewModel(config: config)
        let transactionCoordinator = TransactionCoordinator(
            session: session,
            storage: transactionsStorage,
            keystore: keystore,
            tokensStorage: tokensStorage
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

        if inCoordinatorViewModel.browserAvailable {
            let coordinator = BrowserCoordinator(session: session, keystore: keystore)
            coordinator.start()
            coordinator.rootViewController.tabBarItem = UITabBarItem(
                title: NSLocalizedString("browser.tabbar.item.title", value: "Browser", comment: ""),
                image: R.image.coins(),
                selectedImage: nil
            )
            addCoordinator(coordinator)
            tabBarController.viewControllers?.insert(coordinator.navigationController, at: 0)
        }

        if inCoordinatorViewModel.tokensAvailable {
            let tokenCoordinator = TokensCoordinator(
                session: session,
                keystore: keystore,
                tokensStorage: tokensStorage
            )
            tokenCoordinator.rootViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("tokens.tabbar.item.title", value: "Tokens", comment: ""), image: R.image.coins(), selectedImage: nil)
            tokenCoordinator.delegate = self
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

        let settingsCoordinator = SettingsCoordinator(
            keystore: keystore,
            session: session,
            storage: transactionsStorage
        )
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

        keystore.recentlyUsedWallet = account
    }

    @objc func activateDebug() {
        config.isDebugEnabled = !config.isDebugEnabled

        guard let transactionCoordinator = transactionCoordinator else { return }
        restart(for: transactionCoordinator.session.account, in: transactionCoordinator)
    }

    func restart(for account: Wallet, in coordinator: TransactionCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        coordinator.stop()
        removeAllCoordinators()
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

    func showPaymentFlow(for type: PaymentFlow) {
        guard let transactionCoordinator = transactionCoordinator else { return }
        let session = transactionCoordinator.session
        let tokenStorage = transactionCoordinator.tokensStorage

        switch session.account.type {
        case .real(let account):
            let coordinator = PaymentCoordinator(
                flow: type,
                session: session,
                keystore: keystore,
                storage: tokenStorage,
                account: account
            )
            coordinator.delegate = self
            navigationController.present(coordinator.navigationController, animated: true, completion: nil)
            coordinator.start()
            addCoordinator(coordinator)
        case .watch: break
        }
    }
}

extension InCoordinator: TransactionCoordinatorDelegate {
    func didPress(for type: PaymentFlow, in coordinator: TransactionCoordinator) {
        showPaymentFlow(for: type)
    }

    func didCancel(in coordinator: TransactionCoordinator) {
        delegate?.didCancel(in: self)
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        coordinator.stop()
        removeAllCoordinators()
    }
}

extension InCoordinator: SettingsCoordinatorDelegate {
    func didUpdate(action: SettingsAction, in coordinator: SettingsCoordinator) {
        switch action {
        case .wallets: break
        case .RPCServer, .currency:
            removeCoordinator(coordinator)
            guard let transactionCoordinator = transactionCoordinator else { return }
            restart(for: transactionCoordinator.session.account, in: transactionCoordinator)
        case .pushNotifications:
            break
        }
    }

    func didCancel(in coordinator: SettingsCoordinator) {
        removeCoordinator(coordinator)
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        delegate?.didCancel(in: self)
    }

    func didRestart(with account: Wallet, in coordinator: SettingsCoordinator) {
        guard let transactionCoordinator = transactionCoordinator else { return }
        restart(for: account, in: transactionCoordinator)
    }

    func didUpdateAccounts(in coordinator: SettingsCoordinator) {
        delegate?.didUpdateAccounts(in: self)
    }
}

extension InCoordinator: TokensCoordinatorDelegate {
    func didPress(for type: PaymentFlow, in coordinator: TokensCoordinator) {
        showPaymentFlow(for: type)
    }
}

extension InCoordinator: PaymentCoordinatorDelegate {
    func didCancel(in coordinator: PaymentCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }
}
