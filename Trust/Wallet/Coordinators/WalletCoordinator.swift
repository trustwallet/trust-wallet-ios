// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol WalletCoordinatorDelegate: class {
    func didFinish(with account: Account, in coordinator: WalletCoordinator)
    func didFail(with error: Error, in coordinator: WalletCoordinator)
    func didCancel(in coordinator: WalletCoordinator)
}

class WalletCoordinator {

    let presenterViewController: UINavigationController
    let navigationViewController: UINavigationController
    weak var delegate: WalletCoordinatorDelegate?
    var entryPoint: WalletEntryPoint?
    private let keystore: EtherKeystore

    init(
        presenterViewController: UINavigationController,
        navigationViewController: UINavigationController = NavigationController(),
        keystore: EtherKeystore = EtherKeystore()
    ) {
        self.presenterViewController = presenterViewController
        self.navigationViewController = navigationViewController
        self.navigationViewController.modalPresentationStyle = .formSheet
        self.keystore = EtherKeystore()
    }

    func start(_ entryPoint: WalletEntryPoint) {
        self.entryPoint = entryPoint
        switch entryPoint {
        case .createWallet:
            presentCreateWallet()
        case .importWallet:
            presentImportWallet()
        case .createInstantWallet:
            createInstantWallet()
        }
    }

    func presentCreateWallet() {
        let controller = WelcomeViewController()
        controller.delegate = self
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        navigationViewController.viewControllers = [controller]
        presenterViewController.present(navigationViewController, animated: true, completion: nil)
    }

    func presentImportWallet() {
        let controller: ImportWalletViewController = .make(delegate: self)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        navigationViewController.viewControllers = [controller]
        presenterViewController.present(navigationViewController, animated: true, completion: nil)
    }

    func pushImportWallet() {
        let controller: ImportWalletViewController = .make(delegate: self)
        navigationViewController.pushViewController(controller, animated: true)
    }

    func createInstantWallet() {
        presenterViewController.displayLoading(animated: false)
        let password = UUID().uuidString
        let account = keystore.createAccout(password: password)
        presenterViewController.hideLoading(animated: false)
        didCreateAccount(account: account)
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }

    func didCreateAccount(account: Account) {
        delegate?.didFinish(with: account, in: self)
    }
}

extension WalletCoordinator: WelcomeViewControllerDelegate {
    func didPressImportWallet(in viewController: WelcomeViewController) {
        pushImportWallet()
    }

    func didPressCreateWallet(in viewController: WelcomeViewController) {
        createInstantWallet()
    }
}

extension WalletCoordinator: ImportWalletViewControllerDelegate {
    func didImportAccount(account: Account, in viewController: ImportWalletViewController) {
        didCreateAccount(account: account)
    }
}

extension ImportWalletViewController {
    static func make(delegate: ImportWalletViewControllerDelegate? = .none) -> ImportWalletViewController {
        let controller = ImportWalletViewController()
        controller.delegate = delegate
        return controller
    }
}
