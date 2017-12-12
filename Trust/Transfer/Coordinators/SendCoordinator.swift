// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import BigInt

protocol SendCoordinatorDelegate: class {
    func didCancel(in coordinator: SendCoordinator)
}

class SendCoordinator: Coordinator {

    let transferType: TransferType
    let session: WalletSession
    let navigationController: UINavigationController
    let keystore: Keystore
    var coordinators: [Coordinator] = []
    weak var delegate: SendCoordinatorDelegate?
    lazy var sendViewController: SendViewController = {
        return self.makeSendViewController()
    }()

    init(
        transferType: TransferType,
        navigationController: UINavigationController = UINavigationController(),
        session: WalletSession,
        keystore: Keystore
    ) {
        self.transferType = transferType
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.session = session
        self.keystore = keystore
    }

    func start() {
        navigationController.viewControllers = [sendViewController]
    }

    func makeSendViewController() -> SendViewController {
        let controller = SendViewController(
            session: session,
            transferType: transferType
        )
        controller.navigationItem.titleView = BalanceTitleView.make(from: self.session, transferType)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Next", value: "Next", comment: ""),
            style: .done,
            target: controller,
            action: #selector(SendViewController.send)
        )
        switch transferType {
        case .ether(let destination):
            controller.addressRow?.value = destination?.address
            controller.addressRow?.cell.row.updateCell()
        case .token, .exchange: break
        }
        controller.delegate = self
        return controller
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }
}

extension SendCoordinator: SendViewControllerDelegate {
    func didPressConfirm(transaction: UnconfirmedTransaction, transferType: TransferType, gasPrice: BigInt?, in viewController: SendViewController) {

        let viewModel = ConfirmTransactionHeaderViewModel(
            transaction: transaction,
            config: session.config
        )

        let controller = ConfirmPaymentViewController(
            session: session,
            keystore: keystore,
            transaction: transaction,
            gasPrice: gasPrice,
            headerViewModel: viewModel
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
