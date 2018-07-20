// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustKeystore

protocol WalletsCoordinatorDelegate: class {
    func didSelect(wallet: WalletInfo, in coordinator: WalletsCoordinator)
    func didCancel(in coordinator: WalletsCoordinator)
    func didUpdateAccounts(in coordinator: WalletsCoordinator)
}

class WalletsCoordinator: RootCoordinator {

    var coordinators: [Coordinator] = []
    let keystore: Keystore
    let navigationController: NavigationController
    weak var delegate: WalletsCoordinatorDelegate?

    lazy var rootViewController: UIViewController = {
        return walletController
    }()

    lazy var walletController: WalletsViewController = {
        let controller = WalletsViewController(keystore: keystore)
//        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
//            barButtonSystemItem: .done,
//            target: self,
//            action: #selector(dismiss)
//        )
        controller.delegate = self
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        return controller
    }()

    init(
        keystore: Keystore,
        navigationController: NavigationController = NavigationController()
    ) {
        self.keystore = keystore
        self.navigationController = navigationController
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }

    func start() {
        navigationController.viewControllers = [rootViewController]
        walletController.fetch()
    }

    @objc func add() {
        showCreateWallet()
    }

    func showCreateWallet() {
        let coordinator = WalletCoordinator(keystore: keystore)
        coordinator.delegate = self
        addCoordinator(coordinator)
        coordinator.start(.welcome)
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
    }

    func showWalletInfo(for wallet: WalletInfo, account: Account, sender: UIView) {
        let controller = WalletInfoViewController(
            wallet: wallet,
            account: account
        )
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }

    func exportMnemonic(for account: Wallet) {
        navigationController.topViewController?.displayLoading()
        keystore.exportMnemonic(wallet: account) { [weak self] result in
            self?.navigationController.topViewController?.hideLoading()
            switch result {
            case .success(let words):
                self?.exportMnemonicCoordinator(for: account, words: words)
            case .failure(let error):
                self?.navigationController.topViewController?.displayError(error: error)
            }
        }
    }

    func exportPrivateKeyView(for account: Account) {
        navigationController.topViewController?.displayLoading()
        keystore.exportPrivateKey(account: account) { [weak self] result in
            self?.navigationController.topViewController?.hideLoading()
            switch result {
            case .success(let privateKey):
                self?.exportPrivateKey(with: privateKey)
            case .failure(let error):
                self?.navigationController.topViewController?.displayError(error: error)
            }
        }
    }

    func exportMnemonicCoordinator(for account: Wallet, words: [String]) {
        let coordinator = ExportPhraseCoordinator(
            keystore: keystore,
            account: account,
            words: words
        )
        navigationController.pushCoordinator(coordinator: coordinator, animated: true)
    }

    func exportKeystore(for account: Account) {
        let coordinator = BackupCoordinator(
            navigationController: navigationController,
            keystore: keystore,
            account: account
        )
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
    }

    func exportPrivateKey(with privateKey: Data) {
        let coordinator = ExportPrivateKeyCoordinator(privateKey: privateKey)
        navigationController.pushCoordinator(coordinator: coordinator, animated: true)
    }
}

extension WalletsCoordinator: WalletsViewControllerDelegate {
    func didDeleteAccount(account: WalletInfo, in viewController: WalletsViewController) {
        viewController.fetch()
    }

    func didSelect(wallet: WalletInfo, account: Account, in controller: WalletsViewController) {
        delegate?.didSelect(wallet: wallet, in: self)
    }

    func didSelectForInfo(wallet: WalletInfo, account: Account, in controller: WalletsViewController) {
        showWalletInfo(for: wallet, account: account, sender: controller.view)
    }
}

extension WalletsCoordinator: WalletCoordinatorDelegate {
    func didFinish(with account: WalletInfo, in coordinator: WalletCoordinator) {
        delegate?.didUpdateAccounts(in: self)
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
        walletController.fetch()
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

extension WalletsCoordinator: BackupCoordinatorDelegate {
    func didCancel(coordinator: BackupCoordinator) {
        removeCoordinator(coordinator)
    }

    func didFinish(wallet: Wallet, in coordinator: BackupCoordinator) {
        removeCoordinator(coordinator)
    }
}

extension WalletsCoordinator: WalletInfoViewControllerDelegate {
    func didPress(item: WalletInfoType, in controller: WalletInfoViewController) {
        switch item {
        case .exportKeystore(let account):
            exportKeystore(for: account)
        case .exportPrivateKey(let account):
            exportPrivateKeyView(for: account)
        case .exportRecoveryPhrase(let account):
            exportMnemonic(for: account)
        case .copyAddress(let address):
            controller.showShareActivity(from: controller.view, with: [address.description])
        }
    }

    func didPressSave(wallet: WalletInfo, fields: [WalletInfoField], in controller: WalletInfoViewController) {
        keystore.store(object: wallet.info, fields: fields)
        navigationController.popViewController(animated: true)
    }
}
