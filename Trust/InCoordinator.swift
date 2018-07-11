// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore
import UIKit
import RealmSwift
import URLNavigator
import TrustWalletSDK
import Result

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
    private var pendingTransactionsObserver: NotificationToken?
    var browserCoordinator: BrowserCoordinator? {
        return self.coordinators.compactMap { $0 as? BrowserCoordinator }.first
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

        let walletStorage = WalletStorage(realm: sharedRealm)
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
            account: account,
            config: config,
            balanceCoordinator: balance,
            nonceProvider: nonceProvider
        )
        transactionsStorage.removeTransactions(for: [.failed, .unknown])

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
            browserCoordinator.navigationController.childNavigationController,
            walletCoordinator.navigationController.childNavigationController,
            settingsCoordinator.navigationController.childNavigationController,
        ]

        navigationController.setViewControllers([tabBarController], animated: false)
        navigationController.setNavigationBarHidden(true, animated: false)

        showTab(.wallet(.none))
        keystore.recentlyUsedWallet = account

        let localSchemeCoordinator = LocalSchemeCoordinator(
            navigationController: navigationController,
            keystore: keystore,
            session: session
        )
        localSchemeCoordinator.delegate = self
        addCoordinator(localSchemeCoordinator)
        self.localSchemeCoordinator = localSchemeCoordinator

        observePendingTransactions(from: transactionsStorage)
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
        case .settings:
            break
        }

        tabBarController?.selectedViewController = nav
    }

    func restart(for account: WalletInfo) {
        settingsCoordinator?.rootViewController.navigationItem.leftBarButtonItem = nil
        settingsCoordinator?.rootViewController.networkStateView = nil
        localSchemeCoordinator?.delegate = nil
        localSchemeCoordinator = nil
        navigationController.dismiss(animated: false, completion: nil)
        removeAllCoordinators()
        navigationController.viewControllers.removeAll()
        showTabBar(for: account)
    }

    func checkDevice() {
        let deviceChecker = CheckDeviceCoordinator(
            navigationController: navigationController,
            jailbreakChecker: DeviceChecker()
        )
        deviceChecker.start()
    }

    func showPaymentFlow(for type: PaymentFlow) {
        guard let tokensCoordinator = tokensCoordinator else { return }
        let nav = tokensCoordinator.navigationController
        let session = tokensCoordinator.session
        let tokenStorage = tokensCoordinator.store

        switch (type, session.account.wallet.type) {
        case (.send(let type), .privateKey(let account)),
             (.send(let type), .hd(let account)):
            let coordinator = SendCoordinator(
                transferType: type,
                navigationController: nav,
                session: session,
                keystore: keystore,
                storage: tokenStorage,
                account: account
            )
            coordinator.delegate = self
            addCoordinator(coordinator)
            nav.pushCoordinator(coordinator: coordinator, animated: true)
        case (.request(let token), _):
            let coordinator = RequestCoordinator(
                session: session,
                token: token
            )
            addCoordinator(coordinator)
            nav.pushCoordinator(coordinator: coordinator, animated: true)
        case (.send, .address):
            nav.displayError(error: InCoordinatorError.onlyWatchAccount)
        }
    }

    private func handlePendingTransaction(transaction: SentTransaction) {
        let transaction = SentTransaction.from(from: initialWallet.address, transaction: transaction)
        tokensCoordinator?.transactionsStore.add([transaction])
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

    private func observePendingTransactions(from storage: TransactionsStorage) {
        pendingTransactionsObserver = storage.transactions.observe { [weak self] _ in
            let items = storage.pendingObjects
            self?.tabBarController?.tabBar.items?[Tabs.wallet(.none).index].badgeValue = items.isEmpty ? nil : String(items.count)
        }
    }

    deinit {
        pendingTransactionsObserver?.invalidate()
        pendingTransactionsObserver = nil
    }
}

extension InCoordinator: LocalSchemeCoordinatorDelegate {
    func didCancel(in coordinator: LocalSchemeCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }
}

extension InCoordinator: SettingsCoordinatorDelegate {
    func didCancel(in coordinator: SettingsCoordinator) {
        removeCoordinator(coordinator)
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        delegate?.didCancel(in: self)
    }

    func didRestart(with account: WalletInfo, in coordinator: SettingsCoordinator) {
        restart(for: account)
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

extension InCoordinator: SendCoordinatorDelegate {
    func didFinish(_ result: Result<ConfirmResult, AnyError>, in coordinator: SendCoordinator) {
        switch result {
        case .success(let confirmResult):
            switch confirmResult {
            case .sentTransaction(let transaction):
                handlePendingTransaction(transaction: transaction)
                // TODO. Pop 2 view controllers
                coordinator.navigationController.childNavigationController.popToRootViewController(animated: true)
                removeCoordinator(coordinator)
            case .signedTransaction:
                break
            }
        case .failure(let error):
            coordinator.navigationController.topViewController?.displayError(error: error)
        }
    }
}

extension InCoordinator: BrowserCoordinatorDelegate {
    func didSentTransaction(transaction: SentTransaction, in coordinator: BrowserCoordinator) {
        handlePendingTransaction(transaction: transaction)
    }
}
