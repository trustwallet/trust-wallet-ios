// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol AccountsCoordinatorDelegate: class {
    func didCancel(in coordinator: AccountsCoordinator)
    func didSelectAccount(account: Account, in coordinator: AccountsCoordinator)
    func didAddAccount(account: Account, in coordinator: AccountsCoordinator)
    func didDeleteAccount(account: Account, in coordinator: AccountsCoordinator)
}

class AccountsCoordinator: Coordinator {

    let navigationController: UINavigationController
    var coordinators: [Coordinator] = []

    lazy var accountsViewController: AccountsViewController = {
        let controller = AccountsViewController()
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismiss))
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        controller.allowsAccountDeletion = true
        controller.delegate = self
        return controller
    }()

    weak var delegate: AccountsCoordinatorDelegate?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        navigationController.pushViewController(accountsViewController, animated: false)
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }

    @objc func add() {
        showCreateWallet()
    }

    func showCreateWallet() {
        let coordinator = WalletCoordinator()
        coordinator.delegate = self
        addCoordinator(coordinator)
        coordinator.start(.welcome)
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
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
        delegate?.didAddAccount(account: account, in: self)
        accountsViewController.fetch()
        coordinator.navigationController.dismiss(animated: true, completion: nil)
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
