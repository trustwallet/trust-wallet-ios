// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol AccountsCoordinatorDelegate: class {
    func didCancel(in coordinator: AccountsCoordinator)
    func didSelectAccount(account: Account, in coordinator: AccountsCoordinator)
    func didDeleteAccount(account: Account, in coordinator: AccountsCoordinator)
}

class AccountsCoordinator {

    let navigationController: UINavigationController

    lazy var accountsViewController: AccountsViewController = {
        let controller = AccountsViewController()
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        controller.allowsAccountDeletion = true
        controller.delegate = self
        return controller
    }()

    lazy var rootNavigationController: UINavigationController = {
        let controller = self.accountsViewController
        let nav = NavigationController(rootViewController: controller)
        return nav
    }()

    weak var delegate: AccountsCoordinatorDelegate?

    lazy var walletCoordinator: WalletCoordinator = {
        return WalletCoordinator(rootNavigationController: self.rootNavigationController)
    }()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        navigationController.present(rootNavigationController, animated: true, completion: nil)
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }

    @objc func add() {
        showCreateWallet()
    }

    func showCreateWallet() {
        walletCoordinator.start()
        walletCoordinator.delegate = self
    }
}

extension AccountsCoordinator: AccountsViewControllerDelegate {
    func didSelectAccount(account: Account, in viewController: AccountsViewController) {
        delegate?.didSelectAccount(account: account, in: self)
    }

    func didDeleteAccount(account: Account, in viewController: AccountsViewController) {
        delegate?.didDeleteAccount(account: account, in: self)
    }
}

extension AccountsCoordinator: WalletCoordinatorDelegate {
    func didFinish(with account: Account, in coordinator: WalletCoordinator) {
        accountsViewController.fetch()
        coordinator.navigationViewController.dismiss(animated: true, completion: nil)
    }

    func didFail(with error: Error, in coordinator: WalletCoordinator) {
        coordinator.navigationViewController.dismiss(animated: true, completion: nil)
    }

    func didCancel(in coordinator: WalletCoordinator) {
        coordinator.navigationViewController.dismiss(animated: true, completion: nil)
    }
}
