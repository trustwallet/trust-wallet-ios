// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Result

protocol TransactionCoordinatorDelegate: class {
    func didCancel(in coordinator: TransactionCoordinator)
    func didChangeAccount(to account: Account, in coordinator: TransactionCoordinator)
}

class TransactionCoordinator: Coordinator {

    private let keystore: Keystore

    lazy var rootViewController: TransactionsViewController = {
        let controller = self.makeTransactionsController(with: self.account)
        return controller
    }()

    lazy var dataCoordinator: TransactionDataCoordinator = {
        let coordinator = TransactionDataCoordinator(account: self.account)
        return coordinator
    }()

    weak var delegate: TransactionCoordinatorDelegate?

    lazy var settingsCoordinator: SettingsCoordinator = {
        return SettingsCoordinator(navigationController: self.navigationController)
    }()

    lazy var accountsCoordinator: AccountsCoordinator = {
        return AccountsCoordinator(navigationController: self.navigationController)
    }()

    let account: Account
    let navigationController: UINavigationController
    var coordinators: [Coordinator] = []

    init(
        account: Account,
        rootNavigationController: UINavigationController
    ) {
        self.account = account
        self.keystore = EtherKeystore()
        self.navigationController = rootNavigationController

        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }

    private func makeTransactionsController(with account: Account) -> TransactionsViewController {
        let controller = TransactionsViewController(account: account, dataCoordinator: dataCoordinator)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.settings_icon(), landscapeImagePhone: R.image.settings_icon(), style: UIBarButtonItemStyle.done, target: self, action: #selector(showSettings))
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.accountsSwitch(), landscapeImagePhone: R.image.accountsSwitch(), style: UIBarButtonItemStyle.done, target: self, action: #selector(showAccounts))
        controller.delegate = self
        return controller
    }

    @objc func showAccounts() {
        accountsCoordinator.start()
        accountsCoordinator.delegate = self
    }

    @objc func showSettings() {
        settingsCoordinator.start()
        settingsCoordinator.delegate = self
    }

    func showTokens(for account: Account) {
        let controller = TokensViewController(account: account)
        navigationController.pushViewController(controller, animated: true)
    }

    func showPaymentFlow(for type: PaymentFlow, account: Account) {
        let controller = SendAndRequestViewContainer(flow: type, account: account)
        controller.delegate = self
        let nav = NavigationController(rootViewController: controller)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        navigationController.present(nav, animated: true, completion: nil)
    }

    @objc func didEnterForeground() {
        rootViewController.fetch()
    }

    @objc func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TransactionCoordinator: SettingsCoordinatorDelegate {
    func didUpdate(action: SettingsAction, in coordinator: SettingsCoordinator) {
        switch action {
        case .RPCServer:
            clean()
        case .exportPrivateKey: break
        }
    }

    func didCancel(in coordinator: SettingsCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
    }
}

extension TransactionCoordinator: TransactionsViewControllerDelegate {
    func didPressSend(for account: Account, in viewController: TransactionsViewController) {
        showPaymentFlow(for: .send, account: account)
    }

    func didPressRequest(for account: Account, in viewController: TransactionsViewController) {
        showPaymentFlow(for: .request, account: account)
    }

    func didPressTransaction(transaction: Transaction, in viewController: TransactionsViewController) {
        let controller = TransactionViewController(
            transaction: transaction
        )
        navigationController.pushViewController(controller, animated: true)
    }

    func didPressTokens(for account: Account, in viewController: TransactionsViewController) {
        showTokens(for: account)
    }

    func reset() {
        delegate?.didCancel(in: self)
    }

    func clean() {
        dataCoordinator.storage.deleteAll()
    }
}

extension TransactionCoordinator: AccountsCoordinatorDelegate {
    func didCancel(in coordinator: AccountsCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
    }

    func didSelectAccount(account: Account, in coordinator: AccountsCoordinator) {
        delegate?.didChangeAccount(to: account, in: self)
        clean()
    }

    func didDeleteAccount(account: Account, in coordinator: AccountsCoordinator) {
        guard !coordinator.accountsViewController.hasAccounts else { return }
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        clean()
        reset()
    }
}

extension TransactionCoordinator: SendAndRequestViewContainerDelegate {
    func didCreatePendingTransaction(_ transaction: SentTransaction, in viewController: SendAndRequestViewContainer) {
        dataCoordinator.fetchTransaction(hash: transaction.id)
    }
}
