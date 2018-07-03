// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustCore
import UIKit
import RealmSwift
import URLNavigator
import TrustWalletSDK

protocol InCoordinatorDelegate: class {
    func didCancel(in coordinator: InCoordinator)
    func didUpdateAccounts(in coordinator: InCoordinator)
}

class InCoordinator: Coordinator {

    let navigationController: NavigationController
    var coordinators: [Coordinator] = []
    let initialWallet: WalletInfo
    var keystore: Keystore
    let config: Config
    let appTracker: AppTracker
    let navigator: Navigator
    weak var delegate: InCoordinatorDelegate?
    var browserCoordinator: BrowserCoordinator? {
        return self.coordinators.compactMap { $0 as? BrowserCoordinator }.first
    }
    var transactionCoordinator: TransactionCoordinator? {
        return self.coordinators.compactMap { $0 as? TransactionCoordinator }.first
    }
    var settingsCoordinator: SettingsCoordinator? {
        return self.coordinators.compactMap { $0 as? SettingsCoordinator }.first
    }
    var tokensCoordinator: TokensCoordinator? {
        return self.coordinators.compactMap { $0 as? TokensCoordinator }.first
    }
    var tabBarController: UITabBarController? {
        return self.navigationController.viewControllers.first as? UITabBarController
    }
    var localSchemeCoordinator: LocalSchemeCoordinator?
    lazy var helpUsCoordinator: HelpUsCoordinator = {
        return HelpUsCoordinator(
            navigationController: navigationController,
            appTracker: appTracker
        )
    }()
    let events: [BranchEvent] = []

    init(
        navigationController: NavigationController = NavigationController(),
        wallet: WalletInfo,
        keystore: Keystore,
        config: Config = .current,
        appTracker: AppTracker = AppTracker(),
        navigator: Navigator = Navigator(),
        events: [BranchEvent] = []
    ) {
        self.navigationController = navigationController
        self.initialWallet = wallet
        self.keystore = keystore
        self.config = config
        self.appTracker = appTracker
        self.navigator = navigator
        self.register(with: navigator)
    }

    func start() {
        showTabBar(for: initialWallet)
        checkDevice()

        helpUsCoordinator.start()
        addCoordinator(helpUsCoordinator)
    }

    func showTabBar(for account: WalletInfo) {

        let migration = MigrationInitializer(account: account.wallet, chainID: config.chainID)
        migration.perform()

        let sharedMigration = SharedMigrationInitializer()
        sharedMigration.perform()

        let realm = self.realm(for: migration.config)
        let sharedRealm = self.realm(for: sharedMigration.config)
        let tokensStorage = TokensDataStore(realm: realm, config: config)
        let balanceCoordinator =  TokensBalanceService()
        let viewModel = InCoordinatorViewModel(config: config)
        let trustNetwork = TrustNetwork(
            provider: TrustProviderFactory.makeProvider(),
            APIProvider: TrustProviderFactory.makeAPIProvider(),
            balanceService: balanceCoordinator,
            account: account.wallet,
            config: config
        )
        let balance =  BalanceCoordinator(account: account.wallet, config: config, storage: tokensStorage)
        let transactionsStorage = TransactionsStorage(
            realm: realm,
            account: account.wallet
        )
        let nonceProvider = GetNonceProvider(storage: transactionsStorage)
        let session = WalletSession(
            account: account.wallet,
            config: config,
            balanceCoordinator: balance,
            nonceProvider: nonceProvider
        )
        transactionsStorage.removeTransactions(for: [.failed, .unknown])

        let transactionCoordinator = TransactionCoordinator(
            session: session,
            storage: transactionsStorage,
            tokensStorage: tokensStorage,
            network: trustNetwork,
            keystore: keystore
        )
        transactionCoordinator.rootViewController.tabBarItem = viewModel.transactionsBarItem
        transactionCoordinator.delegate = self
        transactionCoordinator.start()
        addCoordinator(transactionCoordinator)

        let tabBarController = TabBarController()
        tabBarController.tabBar.isTranslucent = false

        let browserCoordinator = BrowserCoordinator(session: session, keystore: keystore, navigator: navigator, sharedRealm: sharedRealm)
        browserCoordinator.delegate = self
        browserCoordinator.start()
        browserCoordinator.rootViewController.tabBarItem = viewModel.browserBarItem
        addCoordinator(browserCoordinator)

        let walletCoordinator = TokensCoordinator(
            session: session,
            keystore: keystore,
            tokensStorage: tokensStorage,
            network: trustNetwork,
            transactionsStore: transactionsStorage
        )
        walletCoordinator.rootViewController.tabBarItem = viewModel.walletBarItem
        walletCoordinator.delegate = self
        walletCoordinator.start()
        addCoordinator(walletCoordinator)

        let walletStorage = WalletStorage(realm: realm)

        let settingsCoordinator = SettingsCoordinator(
            keystore: keystore,
            session: session,
            storage: transactionsStorage,
            walletStorage: walletStorage,
            balanceCoordinator: balanceCoordinator,
            sharedRealm: sharedRealm,
            ensManager: ENSManager(realm: realm, config: config)
        )
        settingsCoordinator.rootViewController.tabBarItem = viewModel.settingsBarItem
        settingsCoordinator.delegate = self
        settingsCoordinator.start()
        addCoordinator(settingsCoordinator)

        tabBarController.viewControllers = [
            browserCoordinator.navigationController,
            walletCoordinator.navigationController,
            transactionCoordinator.navigationController,
            settingsCoordinator.navigationController,
        ]

        navigationController.setViewControllers([tabBarController], animated: false)
        navigationController.setNavigationBarHidden(true, animated: false)
        addCoordinator(transactionCoordinator)

        showTab(.wallet(.none))

        keystore.recentlyUsedWallet = account.wallet

        // activate all view controllers.
        [Tabs.wallet(.none), Tabs.transactions].forEach {
            let _ = (tabBarController.viewControllers?[$0.index] as? NavigationController)?.viewControllers[0].view
        }

        let localSchemeCoordinator = LocalSchemeCoordinator(
            navigationController: navigationController,
            keystore: keystore,
            session: session
        )
        localSchemeCoordinator.delegate = self
        addCoordinator(localSchemeCoordinator)
        self.localSchemeCoordinator = localSchemeCoordinator
    }

    func showTab(_ selectTab: Tabs) {
        guard let viewControllers = tabBarController?.viewControllers else { return }
        guard let nav = viewControllers[selectTab.index] as? UINavigationController else { return }

        switch selectTab {
        case .browser(let url):
            if let url = url {
                browserCoordinator?.openURL(url)
            }
        case .wallet(let action):
            switch action {
            case .none: break
            case .addToken(let address):
                tokensCoordinator?.addTokenContract(for: address)
            }
        case .settings, .transactions:
            break
        }

        tabBarController?.selectedViewController = nav
    }

    func restart(for account: WalletInfo, in coordinator: TransactionCoordinator) {
        settingsCoordinator?.rootViewController.navigationItem.leftBarButtonItem = nil
        settingsCoordinator?.rootViewController.networkStateView = nil
        localSchemeCoordinator?.delegate = nil
        localSchemeCoordinator = nil
        navigationController.dismiss(animated: false, completion: nil)
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        coordinator.stop()
        CookiesStore.delete()
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

        switch (type, session.account.type) {
        case (.send, .privateKey), (.send, .hd), (.request, _):
            let coordinator = PaymentCoordinator(
                flow: type,
                session: session,
                keystore: keystore,
                storage: tokenStorage
            )
            coordinator.delegate = self
            navigationController.present(coordinator.navigationController, animated: true, completion: nil)
            coordinator.start()
            addCoordinator(coordinator)
        case (_, _):
            navigationController.displayError(error: InCoordinatorError.onlyWatchAccount)
        }
    }

    private func handlePendingTransaction(transaction: SentTransaction) {
        transactionCoordinator?.viewModel.addSentTransaction(transaction)
    }

    private func realm(for config: Realm.Configuration) -> Realm {
        return try! Realm(configuration: config)
    }

    @discardableResult
    func handleEvent(_ event: BranchEvent) -> Bool {
        switch event {
        case .openURL(let url):
            showTab(.browser(openURL: url))
        case .newToken(let address):
            showTab(.wallet(.addToken(address)))
        }
        return true
    }
}

extension InCoordinator: LocalSchemeCoordinatorDelegate {
    func didCancel(in coordinator: LocalSchemeCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
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

    func didPressURL(_ url: URL) {
        showTab(.browser(openURL: url))
    }
}

extension InCoordinator: SettingsCoordinatorDelegate {
    func didCancel(in coordinator: SettingsCoordinator) {
        removeCoordinator(coordinator)
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        delegate?.didCancel(in: self)
    }

    func didRestart(with account: Wallet, in coordinator: SettingsCoordinator) {
        guard let transactionCoordinator = transactionCoordinator else { return }
        restart(for: WalletInfo(wallet: account), in: transactionCoordinator)
    }

    func didUpdateAccounts(in coordinator: SettingsCoordinator) {
        delegate?.didUpdateAccounts(in: self)
    }

    func didPressURL(_ url: URL, in coordinator: SettingsCoordinator) {
        showTab(.browser(openURL: url))
    }
}

extension InCoordinator: TokensCoordinatorDelegate {
    func didPress(for type: PaymentFlow, in coordinator: TokensCoordinator) {
        showPaymentFlow(for: type)
    }

    func didPressDiscover(in coordinator: TokensCoordinator) {
        guard let url = Config().openseaURL else { return }
        showTab(.browser(openURL: url))
    }

    func didPress(url: URL, in coordinator: TokensCoordinator) {
        showTab(.browser(openURL: url))
    }
}

extension InCoordinator: PaymentCoordinatorDelegate {
    func didFinish(_ result: ConfirmResult, in coordinator: PaymentCoordinator) {
        switch result {
        case .sentTransaction(let transaction):
            handlePendingTransaction(transaction: transaction)
            coordinator.navigationController.dismiss(animated: true, completion: nil)
            removeCoordinator(coordinator)
        case .signedTransaction:
            break
        }
    }

    func didCancel(in coordinator: PaymentCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }
}

extension InCoordinator: BrowserCoordinatorDelegate {
    func didSentTransaction(transaction: SentTransaction, in coordinator: BrowserCoordinator) {
        handlePendingTransaction(transaction: transaction)
    }
}
