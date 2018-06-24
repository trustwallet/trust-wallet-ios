// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustCore
import TrustKeystore
import UIKit

protocol WalletCoordinatorDelegate: class {
    func didFinish(with account: Wallet, in coordinator: WalletCoordinator)
    func didCancel(in coordinator: WalletCoordinator)
}

class WalletCoordinator: Coordinator {

    let navigationController: NavigationController
    weak var delegate: WalletCoordinatorDelegate?
    var entryPoint: WalletEntryPoint?
    let keystore: Keystore
    var coordinators: [Coordinator] = []

    init(
        navigationController: NavigationController = NavigationController(),
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
        let password = PasswordGenerator.generateRandom()
        keystore.createAccount(with: password) { result in
            switch result {
            case .success(let account):
                self.keystore.exportMnemonic(account: account) { mnemonicResult in
                    self.navigationController.hideLoading(animated: false)
                    switch mnemonicResult {
                    case .success(let words):
                        self.pushBackup(for: account, words: words)
                    case .failure(let error):
                        self.navigationController.displayError(error: error)
                    }
                }
            case .failure(let error):
                self.navigationController.hideLoading(animated: false)
                self.navigationController.displayError(error: error)
            }
        }
    }

    func pushBackup(for account: Account, words: [String]) {
        let controller = PassphraseViewController(
            account: account,
            words: words,
            mode: .showAndVerify
        )
        controller.delegate = self
        controller.navigationItem.backBarButtonItem = nil
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationController.setNavigationBarHidden(false, animated: false)
        navigationController.pushViewController(controller, animated: true)
    }

    @objc func done() {
        delegate?.didCancel(in: self)
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }

    func didCreateAccount(account: Wallet) {
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

    func verify(account: Account, words: [String]) {
        let controller = VerifyPassphraseViewController(account: account, words: words)
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }

    private func shareMnemonic(in sender: UIView, words: [String]) {
        let copyValue = words.joined(separator: " ")
        let activityViewController = UIActivityViewController.make(items: [copyValue])
        activityViewController.popoverPresentationController?.sourceView = sender
        activityViewController.popoverPresentationController?.sourceRect = sender.centerRect
        navigationController.present(activityViewController, animated: true)
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
    func didImportAccount(account: Wallet, in viewController: ImportWalletViewController) {
        didCreateAccount(account: account)
    }
}

extension WalletCoordinator: BackupViewControllerDelegate {
    func didPressBackup(account: Account, in viewController: BackupViewController) {
        backup(account: account)
    }
}

extension WalletCoordinator: PassphraseViewControllerDelegate {
    func didPressVerify(in controller: PassphraseViewController, with account: Account, words: [String]) {
        // show verify
        verify(account: account, words: words)
    }

    func didFinish(in controller: PassphraseViewController, with account: Account) {
        didCreateAccount(account: Wallet(type: .hd(account)))
    }

    func didPressShare(in controller: PassphraseViewController, sender: UIView, account: Account, words: [String]) {
        shareMnemonic(in: sender, words: words)
    }
}

extension WalletCoordinator: VerifyPassphraseViewControllerDelegate {
    func didFinish(in controller: VerifyPassphraseViewController, with account: Account) {
        done()
    }

    func didPressShare(in controller: VerifyPassphraseViewController, sender: UIView, account: Account, words: [String]) {
        shareMnemonic(in: sender, words: words)
    }
}

extension WalletCoordinator: BackupCoordinatorDelegate {
    func didCancel(coordinator: BackupCoordinator) {
        removeCoordinator(coordinator)
    }

    func didFinish(wallet: Wallet, in coordinator: BackupCoordinator) {
        removeCoordinator(coordinator)
        didCreateAccount(account: wallet)
    }
}
