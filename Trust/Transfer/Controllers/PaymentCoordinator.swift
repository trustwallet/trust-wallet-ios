// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol PaymentCoordinatorDelegate: class {
    func didCancel(in coordinator: PaymentCoordinator)
    func didCreatePendingTransaction(_ transaction: SentTransaction, in viewController: PaymentCoordinator)
}

class PaymentCoordinator: Coordinator {

    let session: WalletSession
    weak var delegate: PaymentCoordinatorDelegate?

    lazy var titleView: BalanceTitleView = {
        return BalanceTitleView.make(from: self.session)
    }()
    let flow: PaymentFlow
    var coordinators: [Coordinator] = []

    let navigationController: UINavigationController

    lazy var requestViewController: RequestViewController = {
        return self.makeRequestViewController()
    }()

    lazy var sendViewController: SendViewController = {
        return self.makeSendViewController()
    }()

    lazy var rootViewController: UIViewController = {
        switch self.flow {
        case .request:
            return self.requestViewController
        case .send(let destination):
            return self.sendViewController
        }
    }()

    init(
        navigationController: UINavigationController = UINavigationController(),
        flow: PaymentFlow,
        session: WalletSession
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.session = session
        self.flow = flow

        navigationController.viewControllers = [rootViewController]
    }

    func makeSendViewController() -> SendViewController {
        let controller = SendViewController(account: self.session.account)
        controller.navigationItem.titleView = titleView
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Generic.Next", value: "Next", comment: ""),
            style: .done,
            target: controller,
            action: #selector(SendViewController.send)
        )
        if case .send(let destination) = flow {
            controller.addressRow?.value = destination?.address
            controller.addressRow?.cell.row.updateCell()
        }
        controller.delegate = self
        return controller
    }

    func makeRequestViewController() -> RequestViewController {
        let controller = RequestViewController(account: self.session.account)
        controller.navigationItem.titleView = titleView
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        return controller
    }

    @objc func share() {
        let address = session.account.address.address
        let activityViewController = UIActivityViewController(
            activityItems: [
                NSLocalizedString("Send.MyEthereumAddressIs", value: "My Ethereum address is: ", comment: "") + address,
            ],
            applicationActivities: nil
        )
        activityViewController.popoverPresentationController?.sourceView = requestViewController.view
        navigationController.present(activityViewController, animated: true, completion: nil)
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PaymentCoordinator: SendViewControllerDelegate {
    func didCreatePendingTransaction(_ transaction: SentTransaction, in viewController: SendViewController) {
        delegate?.didCreatePendingTransaction(transaction, in: self)
    }

    func didPressConfirm(transaction: UnconfirmedTransaction, in viewController: SendViewController) {
        let controller = ConfirmPaymentViewController(
            account: session.account,
            transaction: transaction
        )
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }
}

extension PaymentCoordinator: ConfirmPaymentViewControllerDelegate {
    func didCompleted(transaction: SentTransaction, in viewController: ConfirmPaymentViewController) {
        viewController.navigationController?.popViewController(animated: true)
        sendViewController.clear()
        navigationController.displaySuccess(
            title: "Sent! TransactionID: \(transaction.id)",
            message: ""
        )
    }
}
