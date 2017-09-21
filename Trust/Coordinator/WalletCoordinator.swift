// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import UIKit

protocol WalletCoordinatorDelegate: class {
    func didFinish(with account: Account, in coordinator: WalletCoordinator)
    func didFail(with error: Error, in coordinator: WalletCoordinator)
    func didCancel(in coordinator: WalletCoordinator)
}

class WalletCoordinator {
    
    let presenterViewController: UINavigationController
    let navigationViewController: UINavigationController = NavigationController()
    weak var delegate: WalletCoordinatorDelegate?
    
    init(rootNavigationController: UINavigationController) {
        self.presenterViewController = rootNavigationController
    }
    
    func start() {
        showCreateWallet()
    }
    
    func showCreateWallet() {
        let controller: CreateWalletViewController = .make(delegate: self)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        navigationViewController.viewControllers = [controller]
        presenterViewController.present(navigationViewController, animated: true, completion: nil)
    }
    
    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }
    
    func didCreateAccount(account: Account) {
        delegate?.didFinish(with: account, in: self)
    }
}

extension WalletCoordinator: CreateWalletViewControllerDelegate {
    func didPressImport(in viewController: CreateWalletViewController) {
        let controller: ImportWalletViewController = .make(delegate: self)
        navigationViewController.pushViewController(controller, animated: true)
    }
    
    func didCreateAccount(account: Account, in viewController: CreateWalletViewController) {
        didCreateAccount(account: account)
    }
    
    func didCancel(in viewController: CreateWalletViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension WalletCoordinator: ImportWalletViewControllerDelegate {
    func didImportAccount(account: Account, in viewController: ImportWalletViewController) {
        didCreateAccount(account: account)
    }
}

extension CreateWalletViewController {
    static func make(delegate: CreateWalletViewControllerDelegate? = .none) -> CreateWalletViewController {
        let controller = CreateWalletViewController()
        controller.delegate = delegate
        return controller
    }
}

extension ImportWalletViewController {
    static func make(delegate: ImportWalletViewControllerDelegate? = .none) -> ImportWalletViewController {
        let controller = ImportWalletViewController()
        controller.delegate = delegate
        return controller
    }
}

