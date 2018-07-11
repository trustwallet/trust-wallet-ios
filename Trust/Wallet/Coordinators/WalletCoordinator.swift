// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore
import TrustKeystore
import UIKit

protocol WalletCoordinatorDelegate: class {
    func didFinish(with account: WalletInfo, in coordinator: WalletCoordinator)
    func didCancel(in coordinator: WalletCoordinator)
}

final class WalletCoordinator: Coordinator {

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
        navigationController.topViewController?.displayLoading(text: text, animated: false)
        let password = PasswordGenerator.generateRandom()
        keystore.createAccount(with: password) { result in
            switch result {
            case .success(let account):
                self.keystore.exportMnemonic(account: account) { mnemonicResult in
                    self.navigationController.topViewController?.hideLoading(animated: false)
                    switch mnemonicResult {
                    case .success(let words):
                        self.pushBackup(for: account, words: words)
                    case .failure(let error):
                        self.navigationController.displayError(error: error)
                    }
                }
            case .failure(let error):
                self.navigationController.topViewController?.hideLoading(animated: false)
                self.navigationController.topViewController?.displayError(error: error)
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

    func verify(account: Account, words: [String]) {
        let controller = DarkVerifyPassphraseViewController(account: account, words: words)
        controller.delegate = self
        navigationController.setNavigationBarHidden(false, animated: true)
        navigationController.pushViewController(controller, animated: true)
    }

    func walletCreated(wallet: WalletInfo) {
        let controller = WalletCreatedController(wallet: wallet)
        controller.delegate = self
        controller.navigationItem.backBarButtonItem = nil
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationController.setNavigationBarHidden(false, animated: true)
        navigationController.pushViewController(controller, animated: true)
    }

    func showConfirm(for account: Account, completedBackup: Bool) {
        let w = Wallet(type: .hd(account))
        let wallet = WalletInfo(wallet: w, info: WalletObject.from(w))
        let initialName = WalletInfo.initialName(index: keystore.wallets.count - 1)
        keystore.store(object: wallet.info, fields: [
            .name(initialName),
            .backup(completedBackup),
        ])
        walletCreated(wallet: wallet)
    }

    func done(for wallet: WalletInfo) {
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
    func didImportAccount(account: WalletInfo, fields: [WalletInfoField], in viewController: ImportWalletViewController) {
        keystore.store(object: account.info, fields: fields)
        didCreateAccount(account: account)
    }
}

extension WalletCoordinator: PassphraseViewControllerDelegate {
    func didPressVerify(in controller: PassphraseViewController, with account: Account, words: [String]) {
        // show verify
        verify(account: account, words: words)
    }
}

extension WalletCoordinator: VerifyPassphraseViewControllerDelegate {
    func didFinish(in controller: VerifyPassphraseViewController, with account: Account) {
        showConfirm(for: account, completedBackup: true)
    }

    func didSkip(in controller: VerifyPassphraseViewController, with account: Account) {
        controller.confirm(
            title: NSLocalizedString("verifyPassphrase.skip.confirm.title", value: "Are you sure you want to skip this step?", comment: ""),
            message: NSLocalizedString("verifyPassphrase.skip.confirm.message", value: "Loss of backup phrase can put your wallet at risk!", comment: ""),
            okTitle: R.string.localizable.skip(),
            okStyle: .destructive
        ) { [weak self] result in
            switch result {
            case .success:
                self?.showConfirm(for: account, completedBackup: false)
            case .failure: break
            }
        }
    }
}

extension WalletCoordinator: WalletCreatedControllerDelegate {
    func didPressDone(wallet: WalletInfo, in controller: WalletCreatedController) {
        done(for: wallet)
    }
}
