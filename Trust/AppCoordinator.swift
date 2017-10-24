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
        handleNotifications()

        resetToWelcomeScreen()

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

    func handleNotifications() {
        UIApplication.shared.applicationIconBadgeNumber = 0
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
        rootNavigationController.setNavigationBarHidden(false, animated: false)
        addCoordinator(coordinator)

        keystore.recentlyUsedAccount = account
    }

    func showCreateWallet() {
        let coordinator = WalletCoordinator(navigationController: self.rootNavigationController)
        coordinator.delegate = self
        coordinator.start(.createInstantWallet)
        addCoordinator(coordinator)
    }

    func presentImportWallet() {
        let coordinator = WalletCoordinator()
        coordinator.delegate = self
        coordinator.start(.importWallet)
        rootNavigationController.present(coordinator.navigationController, animated: true, completion: nil)
        addCoordinator(coordinator)
    }

    func resetToWelcomeScreen() {
        rootNavigationController.setNavigationBarHidden(true, animated: false)
        rootNavigationController.viewControllers = [welcomeViewController]
    }

    @objc func reset() {
        touchRegistrar.unregister()
        pushNotificationRegistrar.unregister()
        coordinators.removeAll()
        rootNavigationController.dismiss(animated: true, completion: nil)
        resetToWelcomeScreen()
    }

    func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data) {
        pushNotificationRegistrar.didRegister(
            with: deviceToken,
            addresses: keystore.accounts.map { $0.address }
        )
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
