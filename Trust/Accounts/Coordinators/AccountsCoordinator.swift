// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore
import TrustKeystore
import UIKit

protocol AccountsCoordinatorDelegate: class {
    func didCancel(in coordinator: AccountsCoordinator)
    func didSelectAccount(account: WalletInfo, in coordinator: AccountsCoordinator)
    func didAddAccount(account: WalletInfo, in coordinator: AccountsCoordinator)
    func didDeleteAccount(account: WalletInfo, in coordinator: AccountsCoordinator)
}

final class AccountsCoordinator: Coordinator {

    let navigationController: NavigationController
    let keystore: Keystore
    let session: WalletSession
    let balanceCoordinator: TokensBalanceService
    var coordinators: [Coordinator] = []

    lazy var accountsViewController: AccountsViewController = {
        let controller = AccountsViewController(
            keystore: keystore,
            session: session,
            balanceCoordinator: balanceCoordinator
        )
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        controller.delegate = self
        return controller
    }()

    weak var delegate: AccountsCoordinatorDelegate?

    init(
        navigationController: NavigationController,
        keystore: Keystore,
        session: WalletSession,
        balanceCoordinator: TokensBalanceService
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.keystore = keystore
        self.session = session
        self.balanceCoordinator = balanceCoordinator
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
        let coordinator = WalletCoordinator(keystore: keystore)
        coordinator.delegate = self
        addCoordinator(coordinator)
        coordinator.start(.welcome)
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
    }

    func showWalletInfo(for wallet: WalletInfo, sender: UIView) {
        let controller = WalletInfoViewController(
            wallet: wallet
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

extension AccountsCoordinator: AccountsViewControllerDelegate {
    func didSelectAccount(account: WalletInfo, in viewController: AccountsViewController) {
        delegate?.didSelectAccount(account: account, in: self)
    }

    func didDeleteAccount(account: WalletInfo, in viewController: AccountsViewController) {
        delegate?.didDeleteAccount(account: account, in: self)
    }

    func didSelectInfoForAccount(account: WalletInfo, sender: UIView, in viewController: AccountsViewController) {
        showWalletInfo(for: account, sender: sender)
    }
}

extension AccountsCoordinator: WalletCoordinatorDelegate {
    func didFinish(with account: WalletInfo, in coordinator: WalletCoordinator) {
        delegate?.didAddAccount(account: account, in: self)
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
        accountsViewController.fetch()
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

extension AccountsCoordinator: BackupCoordinatorDelegate {
    func didCancel(coordinator: BackupCoordinator) {
        removeCoordinator(coordinator)
    }

    func didFinish(wallet: Wallet, in coordinator: BackupCoordinator) {
        removeCoordinator(coordinator)
    }
}

extension AccountsCoordinator: WalletInfoViewControllerDelegate {
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
