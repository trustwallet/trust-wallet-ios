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
    }

    func inializers() {
        touchRegistrar.register()
    }

    func showTransactions(for account: Account) {
        let coordinator = TransactionCoordinator(
            account: account,
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
        coordinators.removeAll()
        rootNavigationController.dismiss(animated: true, completion: nil)
        rootNavigationController.viewControllers = [welcomeViewController]
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
        removeCoordinator(coordinator)
        reset()
    }

    func didChangeAccount(to account: Account, in coordinator: TransactionCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        showTransactions(for: account)
    }

    func didRestart(with account: Account, in coordinator: TransactionCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
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
