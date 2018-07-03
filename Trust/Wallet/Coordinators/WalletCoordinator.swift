// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustCore
import TrustKeystore
import UIKit

protocol WalletCoordinatorDelegate: class {
    func didFinish(with account: WalletInfo, in coordinator: WalletCoordinator)
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
        let text = String(format: NSLocalizedString("Creating wallet %@", value: "Creating wallet %@", comment: ""), "...")
        navigationController.displayLoading(text: text, animated: false)
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

    func configureWhiteNavigation() {
        navigationController.navigationBar.tintColor = Colors.blue
        navigationController.navigationBar.barTintColor = .white
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
    }

    func pushBackup(for account: Account, words: [String]) {
        configureWhiteNavigation()
        let controller = DarkPassphraseViewController(
            account: account,
            words: words,
            mode: .showAndVerify
        )
        controller.delegate = self
        controller.navigationItem.backBarButtonItem = nil
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationController.setNavigationBarHidden(false, animated: true)
        navigationController.pushViewController(controller, animated: true)
    }

    @objc func done() {
        delegate?.didCancel(in: self)
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }

    func didCreateAccount(account: WalletInfo) {
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
        let controller = DarkVerifyPassphraseViewController(account: account, words: words)
        controller.delegate = self
        navigationController.setNavigationBarHidden(false, animated: true)
        navigationController.pushViewController(controller, animated: true)
    }

    private func shareMnemonic(in sender: UIView, words: [String]) {
        let copyValue = words.joined(separator: " ")
        navigationController.showShareActivity(from: sender, with: [copyValue])
    }

    func done(for account: Account) {
        // TODO
        let w = Wallet(type: .hd(account))
        let wallet = WalletInfo(wallet: w, info: WalletObject.from(w))
        didCreateAccount(account: wallet)
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
    func didImportAccount(account: WalletInfo, in viewController: ImportWalletViewController) {
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
        let wallet = Wallet(type: .hd(account))
        didCreateAccount(account: WalletInfo(wallet: wallet))
    }

    func didPressShare(in controller: PassphraseViewController, sender: UIView, account: Account, words: [String]) {
        shareMnemonic(in: sender, words: words)
    }
}

extension WalletCoordinator: VerifyPassphraseViewControllerDelegate {
    func didFinish(in controller: VerifyPassphraseViewController, with account: Account) {
        done(for: account)
    }

    func didSkip(in controller: VerifyPassphraseViewController, with account: Account) {
        controller.confirm(
            title: NSLocalizedString("verifyPassphrase.skip.confirm.title", value: "Are you sure you want to skip this step?", comment: ""),
            message: NSLocalizedString("verifyPassphrase.skip.confirm.message", value: "Loss of backup phrase can put your wallet at risk!", comment: ""),
            okTitle: NSLocalizedString("Skip", value: "Skip", comment: ""),
            okStyle: .destructive
        ) { [weak self] result in
            switch result {
            case .success: self?.done(for: account)
            case .failure: break
            }
        }
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
        // TODO
        //didCreateAccount(account: wallet)
    }
}
