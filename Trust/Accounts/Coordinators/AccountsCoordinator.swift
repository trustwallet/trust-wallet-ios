// Copyright SIX DAY LLC. All rights reserved.

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

class AccountsCoordinator: Coordinator {

    let navigationController: NavigationController
    let keystore: Keystore
    let session: WalletSession
    let balanceCoordinator: TokensBalanceService
    let ensManager: ENSManager
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
        balanceCoordinator: TokensBalanceService,
        ensManager: ENSManager
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.keystore = keystore
        self.session = session
        self.balanceCoordinator = balanceCoordinator
        self.ensManager = ensManager
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

    func exportMnemonic(for account: Account) {
        navigationController.displayLoading()
        keystore.exportMnemonic(account: account) { [weak self] result in
            self?.navigationController.hideLoading()
            switch result {
            case .success(let words):
                self?.exportMnemonicCoordinator(for: account, words: words)
            case .failure(let error):
                self?.navigationController.displayError(error: error)
            }
        }
    }

    func exportPrivateKeyView(for account: Account) {
        navigationController.displayLoading()
        keystore.exportPrivateKey(account: account) { [weak self] result in
            switch result {
            case .success(let privateKey):
                self?.exportPrivateKey(with: privateKey)
            case .failure(let error):
                self?.navigationController.displayError(error: error)
            }
            self?.navigationController.hideLoading()
        }
    }

    func exportMnemonicCoordinator(for account: Account, words: [String]) {
        let coordinator = ExportPhraseCoordinator(
            keystore: keystore,
            account: account,
            words: words
        )
        coordinator.delegate = self
        coordinator.start()
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
        addCoordinator(coordinator)
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
        let coordinator = ExportPrivateKeyCoordinator(
            privateKey: privateKey
        )
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
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

extension AccountsCoordinator: ExportPhraseCoordinatorDelegate {
    func didCancel(in coordinator: ExportPhraseCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }
}

extension AccountsCoordinator: ExportPrivateKeyCoordinatorDelegate {
    func didCancel(in coordinator: ExportPrivateKeyCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
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
            UIPasteboard.general.string = address.description
        }
    }

    func didPressSave(wallet: WalletInfo, fields: [WalletInfoField], in controller: WalletInfoViewController) {
        keystore.store(object: wallet.info, fields: fields)
        navigationController.popViewController(animated: true)
    }
}
