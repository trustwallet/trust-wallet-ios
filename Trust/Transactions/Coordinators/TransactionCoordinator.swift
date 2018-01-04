// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Result

protocol TransactionCoordinatorDelegate: class {
    func didPress(for type: PaymentFlow, in coordinator: TransactionCoordinator)
    func didCancel(in coordinator: TransactionCoordinator)
}

class TransactionCoordinator: Coordinator {

    private let keystore: Keystore
    let storage: TransactionsStorage
    lazy var rootViewController: TransactionsViewController = {
        return self.makeTransactionsController(with: self.session.account)
    }()

    lazy var dataCoordinator: TransactionDataCoordinator = {
        let coordinator = TransactionDataCoordinator(
            session: self.session,
            storage: self.storage
        )
        return coordinator
    }()

    weak var delegate: TransactionCoordinatorDelegate?

    let session: WalletSession
    let tokensStorage: TokensDataStore
    let navigationController: UINavigationController
    var coordinators: [Coordinator] = []

    init(
        session: WalletSession,
        navigationController: UINavigationController = NavigationController(),
        storage: TransactionsStorage,
        keystore: Keystore,
        tokensStorage: TokensDataStore
    ) {
        self.session = session
        self.keystore = keystore
        self.navigationController = navigationController
        self.storage = storage
        self.tokensStorage = tokensStorage

        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }

    func start() {
        navigationController.viewControllers = [rootViewController]
    }

    private func makeTransactionsController(with account: Account) -> TransactionsViewController {
        let viewModel = TransactionsViewModel()
        let controller = TransactionsViewController(
            account: account,
            dataCoordinator: dataCoordinator,
            session: session,
            tokensStorage: tokensStorage,
            viewModel: viewModel
        )

        let rightItems: [UIBarButtonItem] = {
            switch viewModel.isBuyActionAvailable {
            case true:
                return [
                    UIBarButtonItem(image: R.image.deposit(), landscapeImagePhone: R.image.deposit(), style: .done, target: self, action: #selector(deposit)),
                ]
            case false: return []
            }
        }()
        controller.navigationItem.rightBarButtonItems = rightItems
        controller.delegate = self
        return controller
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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func deposit(sender: UIBarButtonItem) {
        showDeposit(for: session.account, from: sender)
    }

    func showDeposit(for account: Account, from barButtonItem: UIBarButtonItem? = .none) {
        let coordinator = DepositCoordinator(
            navigationController: navigationController,
            account: account
        )
        coordinator.start(from: barButtonItem)
    }
}

extension TransactionCoordinator: TransactionsViewControllerDelegate {
    func didPressSend(in viewController: TransactionsViewController) {
        delegate?.didPress(for: .send(type: .ether(destination: .none)), in: self)
    }

    func didPressRequest(in viewController: TransactionsViewController) {
        delegate?.didPress(for: .request, in: self)
    }

    func didPressTransaction(transaction: Transaction, in viewController: TransactionsViewController) {
        showTransaction(transaction)
    }

    func didPressDeposit(for account: Account, sender: UIView, in viewController: TransactionsViewController) {
        let coordinator = DepositCoordinator(
            navigationController: navigationController,
            account: account
        )
        coordinator.start(from: sender)
    }

    func reset() {
        delegate?.didCancel(in: self)
    }
}
