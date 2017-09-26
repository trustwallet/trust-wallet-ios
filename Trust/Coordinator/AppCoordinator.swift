// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class AppCoordinator: NSObject {

    let rootNavigationController: UINavigationController

    lazy var welcomeViewController: WelcomeViewController = {
        return WelcomeViewController.make(delegate: self)
    }()

    lazy var walletCoordinator: WalletCoordinator = {
        return WalletCoordinator(rootNavigationController: self.rootNavigationController)
    }()

    lazy var settingsCoordinator: SettingsCoordinator = {
        return SettingsCoordinator(navigationController: self.rootNavigationController)
    }()

    lazy var accountsCoordinator: AccountsCoordinator = {
        return AccountsCoordinator(navigationController: self.rootNavigationController)
    }()

    private var keystore: Keystore

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
        rootNavigationController.viewControllers = [welcomeViewController]

        if keystore.hasAccounts {
            showTransactions(for: keystore.recentlyUsedAccount ?? keystore.accounts.first!)
        }
    }

    func showTransactions(for account: Account) {
        let controller = makeTransactionsController(with: account)
        rootNavigationController.viewControllers = [controller]
        keystore.recentlyUsedAccount = account
    }

    func showCreateWallet() {
        walletCoordinator.start()
        walletCoordinator.delegate = self
    }

    private func makeTransactionsController(with account: Account) -> TransactionsViewController {
        let controller = TransactionsViewController(account: account)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.settings_icon(), landscapeImagePhone: R.image.settings_icon(), style: UIBarButtonItemStyle.done, target: self, action: #selector(showSettings))
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.accountsSwitch(), landscapeImagePhone: R.image.accountsSwitch(), style: UIBarButtonItemStyle.done, target: self, action: #selector(showAccounts))
        controller.delegate = self
        return controller
    }

    @objc func dismiss() {
        rootNavigationController.dismiss(animated: true, completion: nil)
    }

    @objc func reset() {
        rootNavigationController.viewControllers = [welcomeViewController]
    }

    @objc func showAccounts() {
        accountsCoordinator.start()
        accountsCoordinator.delegate = self
    }

    @objc func showSettings() {
        settingsCoordinator.start()
        settingsCoordinator.delegate = self
    }

    func showTokens(for account: Account) {
        let controller = TokensViewController(account: account)
        rootNavigationController.pushViewController(controller, animated: true)
    }
}

extension AppCoordinator: WelcomeViewControllerDelegate {
    func didPressStart(in viewController: WelcomeViewController) {
        showCreateWallet()
    }
}

extension AppCoordinator: SettingsCoordinatorDelegate {
    func didCancel(in coordinator: SettingsCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
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

extension AppCoordinator: AccountsCoordinatorDelegate {
    func didCancel(in coordinator: AccountsCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
    }

    func didSelectAccount(account: Account, in coordinator: AccountsCoordinator) {
        showTransactions(for: account)
        coordinator.navigationController.dismiss(animated: true, completion: nil)
    }

    func didDeleteAccount(account: Account, in coordinator: AccountsCoordinator) {
        guard !coordinator.accountsViewController.hasAccounts else { return }
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        rootNavigationController.dismiss(animated: true, completion: nil)
        reset()
    }
}

extension WelcomeViewController {
    static func make(delegate: WelcomeViewControllerDelegate? = .none) -> WelcomeViewController {
        let controller = R.storyboard.welcome.welcome()!
        controller.delegate = delegate
        return controller
    }
}

extension AppCoordinator: TransactionsViewControllerDelegate {
    func didPressSend(for account: Account, in viewController: TransactionsViewController) {
        let controller = SendViewController(account: account)
        let nav = NavigationController(rootViewController: controller)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        rootNavigationController.present(nav, animated: true, completion: nil)
    }

    func didPressRequest(for account: Account, in viewController: TransactionsViewController) {
        let controller = RequestViewController(account: account)
        let nav = NavigationController(rootViewController: controller)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        rootNavigationController.present(nav, animated: true, completion: nil)
    }

    func didPressTransaction(transaction: Transaction, in viewController: TransactionsViewController) {
        let controller = TransactionViewController(transaction: transaction)
        rootNavigationController.pushViewController(controller, animated: true)
    }

    func didPressTokens(for account: Account, in viewController: TransactionsViewController) {
        showTokens(for: account)
    }
}
