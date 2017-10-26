// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class AppCoordinator: NSObject, Coordinator {

    let navigationController: UINavigationController

    lazy var welcomeViewController: WelcomeViewController = {
        let controller = WelcomeViewController()
        controller.delegate = self
        return controller
    }()

    let touchRegistrar = TouchRegistrar()
    let pushNotificationRegistrar = PushNotificationsRegistrar()

    private var keystore: Keystore

    lazy var storage: TransactionsStorage = {
        return TransactionsStorage()
    }()

    var coordinators: [Coordinator] = []

    init(
        window: UIWindow,
        keystore: Keystore = EtherKeystore(),
        navigationController: UINavigationController = NavigationController()
    ) {
        self.keystore = keystore
        self.navigationController = navigationController
        super.init()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    func start() {
        performMigration()
        inializers()
        handleNotifications()

        resetToWelcomeScreen()

        if keystore.hasAccounts {
            showTransactions(for: keystore.recentlyUsedAccount ?? keystore.accounts.first!)
        }

        pushNotificationRegistrar.reRegister()
    }

    func performMigration() {
        MigrationInitializer().perform()
        LokaliseInitializer().perform()
    }

    func inializers() {
        touchRegistrar.register()
    }

    func handleNotifications() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func showTransactions(for account: Account) {
        let session = WalletSession(
            account: account
        )
        let coordinator = TransactionCoordinator(
            session: session,
            rootNavigationController: navigationController,
            storage: storage
        )
        coordinator.delegate = self
        navigationController.viewControllers = [coordinator.rootViewController]
        navigationController.setNavigationBarHidden(false, animated: false)
        addCoordinator(coordinator)

        keystore.recentlyUsedAccount = account
    }

    func showCreateWallet() {
        let coordinator = WalletCoordinator(navigationController: self.navigationController)
        coordinator.delegate = self
        coordinator.start(.createInstantWallet)
        addCoordinator(coordinator)
    }

    func presentImportWallet() {
        let coordinator = WalletCoordinator()
        coordinator.delegate = self
        coordinator.start(.importWallet)
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
        addCoordinator(coordinator)
    }

    func resetToWelcomeScreen() {
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.viewControllers = [welcomeViewController]
    }

    @objc func reset() {
        touchRegistrar.unregister()
        pushNotificationRegistrar.unregister()
        coordinators.removeAll()
        navigationController.dismiss(animated: true, completion: nil)
        resetToWelcomeScreen()
    }

    func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data) {
        pushNotificationRegistrar.didRegister(
            with: deviceToken,
            addresses: keystore.accounts.map { $0.address }
        )
    }

    func showAccounts() {
        let nav = NavigationController()
        let coordinator = AccountsCoordinator(navigationController: nav)
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
    }

    func cleanStorage(for account: Account) {
        storage.deleteAll()
    }
}

extension AppCoordinator: WelcomeViewControllerDelegate {
    func didPressCreateWallet(in viewController: WelcomeViewController) {
        showCreateWallet()
    }

    func didPressImportWallet(in viewController: WelcomeViewController) {
        presentImportWallet()
    }
}

extension AppCoordinator: TransactionCoordinatorDelegate {
    func didCancel(in coordinator: TransactionCoordinator) {
        pushNotificationRegistrar.reRegister()
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        coordinator.stop()
        removeCoordinator(coordinator)
        reset()
    }

    func didRestart(with account: Account, in coordinator: TransactionCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        coordinator.stop()
        removeCoordinator(coordinator)
        showTransactions(for: account)
    }

    func didPressAccounts(in coordinator: TransactionCoordinator) {
        showAccounts()
    }
}

extension AppCoordinator: WalletCoordinatorDelegate {
    func didFinish(with account: Account, in coordinator: WalletCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        showTransactions(for: account)
        removeCoordinator(coordinator)
    }

    func didFail(with error: Error, in coordinator: WalletCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }

    func didCancel(in coordinator: WalletCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }
}

extension AppCoordinator: AccountsCoordinatorDelegate {
    func didAddAccount(account: Account, in coordinator: AccountsCoordinator) {
        pushNotificationRegistrar.reRegister()
    }

    func didDeleteAccount(account: Account, in coordinator: AccountsCoordinator) {
        pushNotificationRegistrar.reRegister()
        guard !coordinator.accountsViewController.hasAccounts else { return }
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        cleanStorage(for: account)
    }

    func didCancel(in coordinator: AccountsCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }

    func didSelectAccount(account: Account, in coordinator: AccountsCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        cleanStorage(for: account)
        removeCoordinator(coordinator)
        showTransactions(for: account)
    }
}
