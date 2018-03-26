// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore
import UIKit
import RealmSwift
import URLNavigator

protocol InCoordinatorDelegate: class {
    func didCancel(in coordinator: InCoordinator)
    func didUpdateAccounts(in coordinator: InCoordinator)
}

class InCoordinator: Coordinator {

    let navigationController: UINavigationController
    var coordinators: [Coordinator] = []
    let initialWallet: Wallet
    var keystore: Keystore
    var config: Config
    let appTracker: AppTracker
    let navigator: Navigator
    weak var delegate: InCoordinatorDelegate?
    var transactionCoordinator: TransactionCoordinator? {
        return self.coordinators.flatMap { $0 as? TransactionCoordinator }.first
    }
    var settingsCoordinator: SettingsCoordinator? {
        return self.coordinators.flatMap { $0 as? SettingsCoordinator }.first
    }
    var tokensCoordinator: TokensCoordinator? {
        return self.coordinators.flatMap { $0 as? TokensCoordinator }.first
    }
    var tabBarController: UITabBarController? {
        return self.navigationController.viewControllers.first as? UITabBarController
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
        appTracker: AppTracker = AppTracker(),
        navigator: Navigator = Navigator()
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

    func showTabBar(for account: Wallet) {

        let migration = MigrationInitializer(account: account, chainID: config.chainID)
        migration.perform()

        let web3 = self.web3(for: config.server)
        web3.start()
        let realm = self.realm(for: migration.config)
        let tokensStorage = TokensDataStore(realm: realm, config: config)
        let balanceCoordinator =  TokensBalanceService(web3: web3)
        let trustNetwork = TrustNetwork(provider: TrustProviderFactory.makeProvider(), balanceService: balanceCoordinator, account: account, config: config)
        let balance =  BalanceCoordinator(account: account, config: config, storage: tokensStorage)
        let session = WalletSession(
            account: account,
            config: config,
            web3: web3,
            balanceCoordinator: balance
        )
        let transactionsStorage = TransactionsStorage(
            realm: realm
        )
        transactionsStorage.removeTransactions(for: [.failed, .pending, .unknown])

        let inCoordinatorViewModel = InCoordinatorViewModel(config: config)
        let transactionCoordinator = TransactionCoordinator(
            session: session,
            storage: transactionsStorage,
            tokensStorage: tokensStorage,
            network: trustNetwork,
            keystore: keystore
        )
        transactionCoordinator.rootViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("transactions.tabbar.item.title", value: "Transactions", comment: ""), image: R.image.feed(), selectedImage: nil)
        transactionCoordinator.delegate = self
        transactionCoordinator.start()
        addCoordinator(transactionCoordinator)

        let tabBarController = TabBarController()

        tabBarController.tabBar.isTranslucent = false

        let browserCoordinator = BrowserCoordinator(session: session, keystore: keystore, navigator: navigator, realm: realm)
        browserCoordinator.delegate = self
        browserCoordinator.start()
        browserCoordinator.rootViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("browser.tabbar.item.title", value: "Browser", comment: ""),
            image: R.image.dapps_icon(),
            selectedImage: nil
        )
        addCoordinator(browserCoordinator)

        let walletCoordinator = TokensCoordinator(
            session: session,
            keystore: keystore,
            tokensStorage: tokensStorage,
            network: trustNetwork,
            transactionsStore: transactionsStorage
        )
        walletCoordinator.rootViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("wallet.navigation.title", value: "Wallet", comment: ""),
            image: R.image.settingsWallet(),
            selectedImage: nil
        )
        walletCoordinator.delegate = self
        walletCoordinator.start()
        addCoordinator(walletCoordinator)
        let settingsCoordinator = SettingsCoordinator(
            keystore: keystore,
            session: session,
            storage: transactionsStorage,
            balanceCoordinator: balanceCoordinator
        )
        settingsCoordinator.rootViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("settings.navigation.title", value: "Settings", comment: ""),
            image: R.image.settings_icon(),
            selectedImage: nil
        )
        settingsCoordinator.delegate = self
        settingsCoordinator.start()
        addCoordinator(settingsCoordinator)

        tabBarController.viewControllers = [
            browserCoordinator.navigationController,
            walletCoordinator.navigationController,
            transactionCoordinator.navigationController,
            settingsCoordinator.navigationController,
        ]

        navigationController.setViewControllers(
            [tabBarController],
            animated: false
        )
        navigationController.setNavigationBarHidden(true, animated: false)
        addCoordinator(transactionCoordinator)

        showTab(.wallet)

        keystore.recentlyUsedWallet = account
    }

    func showTab(_ selectTab: Tabs) {
        guard let viewControllers = tabBarController?.viewControllers else { return }
        guard let nav = viewControllers[selectTab.index] as? UINavigationController else { return }

        switch selectTab {
        case .browser(let openURL):
            if let openURL = openURL, let controller = nav.viewControllers[0] as? BrowserViewController {
                controller.goTo(url: openURL)
            }
        case .settings, .wallet, .transactions:
            break
        }

        tabBarController?.selectedViewController = nav
    }

    func restart(for account: Wallet, in coordinator: TransactionCoordinator) {
        tokensCoordinator?.tokensViewController.cancelOperations()
        settingsCoordinator?.rootViewController.navigationItem.leftBarButtonItem = nil
        settingsCoordinator?.rootViewController.networkStateView = nil
        navigationController.dismiss(animated: false, completion: nil)
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

    private func web3(for server: RPCServer) -> Web3Swift {
        return Web3Swift(url: config.server.rpcURL)
    }

    private func showTransactionSent(transaction: SentTransaction) {
        let alertController = UIAlertController(title: NSLocalizedString("sent.transaction.title", value: "Transaction Sent!", comment: ""),
                                                message: NSLocalizedString("sent.transaction.message", value: "Wait for the transaction to be mined on the network to see details.", comment: ""),
                                                preferredStyle: UIAlertControllerStyle.alert)
        let copyAction = UIAlertAction(title: NSLocalizedString("send.action.copy.transaction.title", value: "Copy Transaction ID", comment: ""), style: UIAlertActionStyle.default, handler: { _ in
            UIPasteboard.general.string = transaction.id
        })
        alertController.addAction(copyAction)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", value: "OK", comment: ""), style: UIAlertActionStyle.default, handler: nil))
        navigationController.present(alertController, animated: true, completion: nil)
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

    func didPressDiscover(in coordinator: TokensCoordinator) {
        guard let url = URL(string: Constants.dappsOpenSea) else { return }
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
            showTransactionSent(transaction: transaction)
            removeCoordinator(coordinator)

            // Once transaction sent, show transactions screen.
            showTab(.transactions)
        case .signedTransaction: break
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
