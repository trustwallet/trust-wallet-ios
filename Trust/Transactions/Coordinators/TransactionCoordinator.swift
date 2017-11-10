// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Result

protocol TransactionCoordinatorDelegate: class {
    func didCancel(in coordinator: TransactionCoordinator)
    func didRestart(with account: Account, in coordinator: TransactionCoordinator)
    func didUpdateAccounts(in coordinator: TransactionCoordinator)
}

class TransactionCoordinator: Coordinator {

    private let keystore: Keystore
    let storage: TransactionsStorage
    lazy var rootViewController: TransactionsViewController = {
        return self.makeTransactionsController(with: self.session.account)
    }()

    lazy var dataCoordinator: TransactionDataCoordinator = {
        let coordinator = TransactionDataCoordinator(
            account: self.session.account,
            storage: self.storage
        )
        return coordinator
    }()

    weak var delegate: TransactionCoordinatorDelegate?

    let session: WalletSession
    let navigationController: UINavigationController
    var coordinators: [Coordinator] = []

    init(
        session: WalletSession,
        rootNavigationController: UINavigationController,
        storage: TransactionsStorage,
        keystore: Keystore
    ) {
        self.session = session
        self.keystore = keystore
        self.navigationController = rootNavigationController
        self.storage = storage

        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }

    private func makeTransactionsController(with account: Account) -> TransactionsViewController {
        let controller = TransactionsViewController(
            account: account,
            dataCoordinator: dataCoordinator,
            session: session
        )
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.settings_icon(), landscapeImagePhone: R.image.settings_icon(), style: UIBarButtonItemStyle.done, target: self, action: #selector(showSettings))
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.accountsSwitch(), landscapeImagePhone: R.image.accountsSwitch(), style: UIBarButtonItemStyle.done, target: self, action: #selector(showAccounts))
        controller.delegate = self
        return controller
    }

    @objc func showSettings() {
        let coordinator = SettingsCoordinator()
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
    }

    func showTokens(for account: Account) {
        let coordinator = TokensCoordinator(
            session: session
        )
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
    }

    func showTransaction(_ transaction: Transaction) {
        let controller = TransactionViewController(
            session: session,
            transaction: transaction
        )
        if UIDevice.current.userInterfaceIdiom == .pad {
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .formSheet
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
            navigationController.present(nav, animated: true, completion: nil)
        } else {
            navigationController.pushViewController(controller, animated: true)
        }
    }

    func showPaymentFlow(for type: PaymentFlow, session: WalletSession) {
        let coordinator = PaymentCoordinator(
            flow: type,
            session: session
        )
        coordinator.delegate = self
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
        coordinator.start()
        addCoordinator(coordinator)
    }

    @objc func didEnterForeground() {
        rootViewController.fetch()
    }

    @objc func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
    }

    func stop() {
        dataCoordinator.stop()
        session.stop()
    }

    func restart(for account: Account) {
        delegate?.didRestart(with: account, in: self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func showAccounts() {
        let nav = NavigationController()
        let coordinator = AccountsCoordinator(navigationController: nav)
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
    }
}

extension TransactionCoordinator: SettingsCoordinatorDelegate {
    func didUpdate(action: SettingsAction, in coordinator: SettingsCoordinator) {
        switch action {
        case .RPCServer:
            removeCoordinator(coordinator)
            restart(for: session.account)
        case .exportPrivateKey, .pushNotifications:
            break
        case .donate(let address):
            coordinator.navigationController.dismiss(animated: true) {
                self.showPaymentFlow(for: .send(type: .ether(destination: address)), session: self.session)
            }
            removeCoordinator(coordinator)
        }
    }

    func didCancel(in coordinator: SettingsCoordinator) {
        removeCoordinator(coordinator)
        coordinator.navigationController.dismiss(animated: true, completion: nil)
    }
}

extension TransactionCoordinator: TransactionsViewControllerDelegate {
    func didPressSend(in viewController: TransactionsViewController) {
        showPaymentFlow(for: .send(type: .ether(destination: .none)), session: session)
    }

    func didPressRequest(in viewController: TransactionsViewController) {
        showPaymentFlow(for: .request, session: session)
    }

    func didPressTransaction(transaction: Transaction, in viewController: TransactionsViewController) {
        showTransaction(transaction)
    }

    func didPressTokens(in viewController: TransactionsViewController) {
        showTokens(for: session.account)
    }

    func didPressDeposit(for account: Account, in viewController: TransactionsViewController) {
        let coordinator = DepositCoordinator(
            navigationController: navigationController,
            account: account
        )
        coordinator.start()
    }

    func reset() {
        delegate?.didCancel(in: self)
    }
}

extension TransactionCoordinator: PaymentCoordinatorDelegate {
    func didCancel(in coordinator: PaymentCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }
}

extension TransactionCoordinator: AccountsCoordinatorDelegate {
    func didAddAccount(account: Account, in coordinator: AccountsCoordinator) {
        delegate?.didUpdateAccounts(in: self)
    }

    func didDeleteAccount(account: Account, in coordinator: AccountsCoordinator) {
        storage.delete(for: account)
        delegate?.didUpdateAccounts(in: self)
        guard !coordinator.accountsViewController.hasAccounts else { return }
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        delegate?.didCancel(in: self)
    }

    func didCancel(in coordinator: AccountsCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }

    func didSelectAccount(account: Account, in coordinator: AccountsCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
        delegate?.didRestart(with: account, in: self)
    }
}

extension TransactionCoordinator: TokensCoordinatorDelegate {
    func didCancel(in coordinator: TokensCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }
}
