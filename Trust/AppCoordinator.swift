// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class AppCoordinator: NSObject, Coordinator {

    let rootNavigationController: UINavigationController

    lazy var welcomeViewController: WelcomeViewController = {
        let controller = WelcomeViewController()
        controller.delegate = self
        return controller
    }()

    lazy var walletCoordinator: WalletCoordinator = {
        return WalletCoordinator(rootNavigationController: self.rootNavigationController)
    }()
    let touchRegistrar = TouchRegistrar()
    let pushNotificationRegistrar = PushNotificationsRegistrar()

    private var keystore: Keystore

    var coordinators: [Coordinator] = []

    init(
        window: UIWindow,
        keystore: Keystore = EtherKeystore(),
        rootNavigationController: UINavigationController = NavigationController()
    ) {
        self.keystore = keystore
        self.rootNavigationController = rootNavigationController
        super.init()
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()
    }

    func start() {
        performMigration()
        inializers()

        rootNavigationController.viewControllers = [welcomeViewController]

        if keystore.hasAccounts {
            showTransactions(for: keystore.recentlyUsedAccount ?? keystore.accounts.first!)
        }
    }

    func performMigration() {
        MigrationInitializer().perform()
        LokaliseInitializer().perform()
    }

    func inializers() {
        touchRegistrar.register()
    }

    func showTransactions(for account: Account) {
        let session = WalletSession(
            account: account
        )
        let coordinator = TransactionCoordinator(
            session: session,
            rootNavigationController: rootNavigationController
        )
        coordinator.delegate = self
        rootNavigationController.viewControllers = [coordinator.rootViewController]
        addCoordinator(coordinator)

        keystore.recentlyUsedAccount = account
    }

    func showCreateWallet() {
        walletCoordinator.start()
        walletCoordinator.delegate = self
    }

    @objc func reset() {
        touchRegistrar.unregister()
        pushNotificationRegistrar.unregister()
        coordinators.removeAll()
        rootNavigationController.dismiss(animated: true, completion: nil)
        rootNavigationController.viewControllers = [welcomeViewController]
    }

    func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data) {
        pushNotificationRegistrar.didRegister(
            with: deviceToken,
            addresses: keystore.accounts.map { $0.address }
        )
    }
}

extension AppCoordinator: WelcomeViewControllerDelegate {
    func didPressStart(in viewController: WelcomeViewController) {
        showCreateWallet()
    }
}

extension AppCoordinator: TransactionCoordinatorDelegate {
    func didCancel(in coordinator: TransactionCoordinator) {
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
}

extension AppCoordinator: WalletCoordinatorDelegate {
    func didFinish(with account: Account, in coordinator: WalletCoordinator) {
        showTransactions(for: account)
        coordinator.navigationViewController.dismiss(animated: true, completion: nil)
    }

    func didFail(with error: Error, in coordinator: WalletCoordinator) {
        coordinator.navigationViewController.dismiss(animated: true, completion: nil)
    }

    func didCancel(in coordinator: WalletCoordinator) {
        coordinator.navigationViewController.dismiss(animated: true, completion: nil)
    }
}
