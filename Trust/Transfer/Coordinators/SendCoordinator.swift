// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol SendCoordinatorDelegate: class {
    func didCancel(in coordinator: SendCoordinator)
}

class SendCoordinator: Coordinator {

    let transferType: TransferType
    let session: WalletSession
    let navigationController: UINavigationController
    var coordinators: [Coordinator] = []
    weak var delegate: SendCoordinatorDelegate?
    lazy var sendViewController: SendViewController = {
        return self.makeSendViewController()
    }()

    init(
        transferType: TransferType,
        navigationController: UINavigationController = UINavigationController(),
        session: WalletSession
    ) {
        self.transferType = transferType
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.session = session
    }

    func start() {
        navigationController.viewControllers = [sendViewController]
    }

    func makeSendViewController() -> SendViewController {
        let controller = SendViewController(
            account: session.account,
            transferType: transferType
        )
        controller.navigationItem.titleView = BalanceTitleView.make(from: self.session)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Generic.Next", value: "Next", comment: ""),
            style: .done,
            target: controller,
            action: #selector(SendViewController.send)
        )
        switch transferType {
        case .ether(let destination):
            controller.addressRow?.value = destination?.address
            controller.addressRow?.cell.row.updateCell()
        case .token: break
        }
        controller.delegate = self
        return controller
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }
}

extension SendCoordinator: SendViewControllerDelegate {
    func didPressConfirm(transaction: UnconfirmedTransaction, transferType: TransferType, in viewController: SendViewController) {
        let controller = ConfirmPaymentViewController(
            session: session,
            transaction: transaction,
            transferType: transferType
        )
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }

    func didCreatePendingTransaction(_ transaction: SentTransaction, in viewController: SendViewController) {

    }
}

extension SendCoordinator: ConfirmPaymentViewControllerDelegate {
    func didCompleted(transaction: SentTransaction, in viewController: ConfirmPaymentViewController) {
        viewController.navigationController?.popViewController(animated: true)
        sendViewController.clear()
        navigationController.displaySuccess(
            title: "Sent! TransactionID: \(transaction.id)",
            message: ""
        )
    }
}
