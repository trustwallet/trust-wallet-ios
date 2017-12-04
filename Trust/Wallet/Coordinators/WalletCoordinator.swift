// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol WalletCoordinatorDelegate: class {
    func didFinish(with account: Account, in coordinator: WalletCoordinator)
    func didCancel(in coordinator: WalletCoordinator)
}

class WalletCoordinator: Coordinator {

    let navigationController: UINavigationController
    weak var delegate: WalletCoordinatorDelegate?
    var entryPoint: WalletEntryPoint?
    let keystore: Keystore
    var coordinators: [Coordinator] = []

    init(
        navigationController: UINavigationController = NavigationController(),
        keystore: Keystore
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.keystore = keystore
    }

    func start(_ entryPoint: WalletEntryPoint) {
        self.entryPoint = entryPoint
        switch entryPoint {
        case .welcome:
            let controller = WelcomeViewController()
            controller.delegate = self
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
            navigationController.viewControllers = [controller]
        case .importWallet:
            let controller = ImportWalletViewController(keystore: keystore)
            controller.delegate = self
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
            navigationController.viewControllers = [controller]
        case .createInstantWallet:
            createInstantWallet()
        }
    }

    func pushImportWallet() {
        let controller = ImportWalletViewController(keystore: keystore)
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }

    func createInstantWallet() {
        navigationController.displayLoading(text: "Creating wallet...", animated: false)
        let password = UUID().uuidString
        keystore.createAccount(with: password) { result in
            switch result {
            case .success(let account):
                self.pushBackup(for: account)
            case .failure(let error):
                self.navigationController.displayError(error: error)
            }
            self.navigationController.hideLoading(animated: false)
        }
    }

    func pushBackup(for account: Account) {
        let controller = BackupViewController(account: account)
        controller.delegate = self
        controller.navigationItem.backBarButtonItem = nil
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.pushViewController(controller, animated: true)
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }

    func didCreateAccount(account: Account) {
        delegate?.didFinish(with: account, in: self)
    }

    func backup(account: Account) {
        let coordinator = BackupCoordinator(
            navigationController: navigationController,
            keystore: keystore,
            account: account
        )
        coordinator.delegate = self
        addCoordinator(coordinator)
        coordinator.start()
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

extension WalletCoordinator: BackupViewControllerDelegate {
    func didPressBackup(account: Account, in viewController: BackupViewController) {
        backup(account: account)
    }

    func didPressLater(account: Account, in viewController: BackupViewController) {
        navigationController.confirm(
            title: "Watch out!",
            message: "If this device is replaced or this app is deleted, neither you nor Trust Wallet can recover your funds without a backup",
            okTitle: "I understand",
            okStyle: .destructive
        ) { result in
            switch result {
            case .success:
                self.delegate?.didFinish(with: account, in: self)
            case .failure:
                break
            }
        }
    }
}

extension WalletCoordinator: BackupCoordinatorDelegate {
    func didCancel(coordinator: BackupCoordinator) {
        removeCoordinator(coordinator)
    }

    func didFinish(account: Account, in coordinator: BackupCoordinator) {
        removeCoordinator(coordinator)
        didCreateAccount(account: account)
    }
}
