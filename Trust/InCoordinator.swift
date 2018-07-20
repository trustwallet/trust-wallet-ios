// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore
import TrustKeystore
import UIKit
import RealmSwift
import URLNavigator
import TrustWalletSDK
import Result

protocol InCoordinatorDelegate: class {
    func didCancel(in coordinator: InCoordinator)
    func didUpdateAccounts(in coordinator: InCoordinator)
}

enum CoinType {
    case coin(Account, TokenObject)
    case tokenOf(Account, TokenObject)
}

struct CoinTypeViewModel {

    let type: CoinType

    var account: Account {
        switch type {
        case .coin(let account,_):
            return account
        case .tokenOf(let account,_):
            return account
        }
    }

    var address: String {
        switch type {
        case .coin(let account, _):
            return account.address.description
        case .tokenOf(let account, _):
            return account.address.description
        }
    }

    var name: String {
        switch type {
        case .coin(_, let token):
            return token.name
        case .tokenOf(_, let token):
            return token.name
        }
    }

    var server: RPCServer {
        switch account.coin! {
        case .ethereum: return RPCServer.main
        case .ethereumClassic: return RPCServer.classic
        case .gochain: return RPCServer.gochain
        case .poa: return RPCServer.poa
        case .callisto: return RPCServer.callisto
        case .bitcoin: return RPCServer.main
        }
    }
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

    lazy var walletsCoordinator: WalletsCoordinator = {
        let coordinator = WalletsCoordinator(keystore: keystore)
        coordinator.delegate = self
        return coordinator
    }()

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

        walletsCoordinator.start()
    }

    func showTabBar(for account: WalletInfo) {

        let migration = MigrationInitializer(account: account)
        migration.perform()

        let sharedMigration = SharedMigrationInitializer()
        sharedMigration.perform()

        let realm = self.realm(for: migration.config)
        let sharedRealm = self.realm(for: sharedMigration.config)

        let viewModel = InCoordinatorViewModel(config: config)

        let session = WalletSession(
            account: account,
            realm: realm,
            sharedRealm: sharedRealm,
            config: config
        )
        session.transactionsStorage.removeTransactions(for: [.failed, .unknown])

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
            tokensStorage: session.tokensStorage,
            transactionsStore: session.transactionsStorage
        )
        walletCoordinator.rootViewController.tabBarItem = viewModel.walletBarItem
        walletCoordinator.delegate = self
        walletCoordinator.start()
        addCoordinator(walletCoordinator)

        let settingsCoordinator = SettingsCoordinator(
            keystore: keystore,
            session: session,
            storage: session.transactionsStorage,
            walletStorage: session.walletStorage,
            sharedRealm: sharedRealm
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

        observePendingTransactions(from: session.transactionsStorage)
    }

    func changeWallet() {
        walletsCoordinator.walletController.tableView.scrollOnTop()
        navigationController.present(walletsCoordinator.navigationController, animated: true)
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

//    func showPaymentFlow(for type: PaymentFlow) {
//        guard let tokensCoordinator = tokensCoordinator else { return }
//        let nav = tokensCoordinator.navigationController
//        let session = tokensCoordinator.session
//        let tokenStorage = tokensCoordinator.store
//
//        guard let coin = token.coin else { return }
//        let acc = session.account.accounts.filter { $0.coin == coin }.first!
//
//        switch (type, session.account.type) {
//        case (.send(let type), .privateKey(let account)),
//             (.send(let type), .hd(let account)):
//
//
//        case (.request(let token), _):
//
//        case (.send, .address):
//            nav.displayError(error: InCoordinatorError.onlyWatchAccount)
//        }
//    }

    func sendFlow(for token: TokenObject) {
        guard let tokensCoordinator = tokensCoordinator else { return }
        let nav = tokensCoordinator.navigationController
        let session = tokensCoordinator.session

        let transfer: Transfer = {
            if token.isCoin {
                let server = RPCServer(chainID: token.chainID)!
                let transfer = Transfer(server: server, type: .ether(destination: .none))
                return transfer
            } else {
                let server = RPCServer.main
                let transfer = Transfer(server: server, type: .token(token))
                return transfer
            }
        }()

        let coordinator = SendCoordinator(
            transfer: transfer,
            navigationController: nav,
            session: session,
            keystore: keystore,
            account: session.account.currentAccount
        )
        coordinator.delegate = self
        addCoordinator(coordinator)
        nav.pushCoordinator(coordinator: coordinator, animated: true)
    }

    func requestFlow(for token: TokenObject) {
        guard let tokensCoordinator = tokensCoordinator else { return }
        let nav = tokensCoordinator.navigationController
        let session = tokensCoordinator.session

        guard let coin = token.coin else { return }
        let acc = session.account.accounts.filter { $0.coin == coin }.first!

        let viewModel = CoinTypeViewModel(type: .coin(acc, token))
        let coordinator = RequestCoordinator(
            session: session,
            coinTypeViewModel: viewModel
        )
        addCoordinator(coordinator)
        nav.pushCoordinator(coordinator: coordinator, animated: true)
    }

    private func handlePendingTransaction(transaction: SentTransaction) {
        guard let address = initialWallet.address as? EthereumAddress else { return }
        let transaction = SentTransaction.from(from: address, transaction: transaction)
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

    func didPressURL(_ url: URL, in coordinator: SettingsCoordinator) {
        showTab(.browser(openURL: url))
    }
}

extension InCoordinator: TokensCoordinatorDelegate {
    func didPressSend(for token: TokenObject, in coordinator: TokensCoordinator) {
        sendFlow(for: token)
    }

    func didPressRequest(for token: TokenObject, in coordinator: TokensCoordinator) {
        requestFlow(for: token)
    }

    func didPressDiscover(in coordinator: TokensCoordinator) {
        //Refactor
        //guard let url = Config().openseaURL else { return }
        //showTab(.browser(openURL: url))
    }

    func didPress(url: URL, in coordinator: TokensCoordinator) {
        showTab(.browser(openURL: url))
    }

    func didPressChangeWallet(in coordinator: TokensCoordinator) {
        changeWallet()
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

extension InCoordinator: WalletsCoordinatorDelegate {
    func didUpdateAccounts(in coordinator: WalletsCoordinator) {
        delegate?.didUpdateAccounts(in: self)
    }

    func didSelect(wallet: WalletInfo, in coordinator: WalletsCoordinator) {
        coordinator.navigationController.dismiss(animated: true)
        // removeCoordinator(coordinator)
        restart(for: wallet)
    }
    func didCancel(in coordinator: WalletsCoordinator) {
        navigationController.dismiss(animated: true)
        // removeCoordinator(coordinator)
    }
}
