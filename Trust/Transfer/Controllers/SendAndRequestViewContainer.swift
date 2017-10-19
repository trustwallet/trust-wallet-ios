// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol SendAndRequestViewContainerDelegate: class {
    func didCreatePendingTransaction(_ transaction: SentTransaction, in viewController: SendAndRequestViewContainer)
}

class SendAndRequestViewContainer: UIViewController {

    let session: WalletSession
    weak var delegate: SendAndRequestViewContainerDelegate?

    lazy var sendViewController: SendViewController = {
        let controller = SendViewController(account: self.session.account)
        controller.delegate = self
        return controller
    }()

    lazy var titleView: BalanceTitleView = {
        return BalanceTitleView.make(from: self.session)
    }()

    lazy var requestController: RequestViewController = {
        let controller = RequestViewController(account: self.session.account)
        return controller
    }()

    lazy var nextButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(
            title: NSLocalizedString("Generic.Next", value: "Next", comment: ""),
            style: .done,
            target: self.sendViewController,
            action: #selector(SendViewController.send)
        )
    }()

    lazy var shareButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
    }()

    init(
        flow: PaymentFlow,
        session: WalletSession
    ) {
        self.session = session
        super.init(nibName: nil, bundle: nil)

        navigationItem.titleView = titleView
        view.backgroundColor = .white

        if case let .send(destination) = flow {
            sendViewController.addressRow?.value = destination?.address
            sendViewController.addressRow?.updateCell()
        }

        updateTo(flow: flow)
    }

    func updateTo(flow: PaymentFlow) {
        switch flow {
        case .send:
            add(asChildViewController: sendViewController)
            remove(asChildViewController: requestController)
            navigationItem.rightBarButtonItem = nextButtonItem
        case .request:
            add(asChildViewController: requestController)
            remove(asChildViewController: sendViewController)
            navigationItem.rightBarButtonItem = shareButton
        }
    }

    @objc func share() {
        let address = session.account.address.address
        let activityViewController = UIActivityViewController(
            activityItems: [
                NSLocalizedString("Send.MyEthereumAddressIs", value: "My Ethereum address is: ", comment: "") + address,
            ],
            applicationActivities: nil
        )
        activityViewController.popoverPresentationController?.sourceView = view
        present(activityViewController, animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SendAndRequestViewContainer: SendViewControllerDelegate {
    func didCreatePendingTransaction(_ transaction: SentTransaction, in viewController: SendViewController) {
        delegate?.didCreatePendingTransaction(transaction, in: self)
    }

    func didPressConfirm(transaction: UnconfirmedTransaction, in viewController: SendViewController) {
        let controller = ConfirmPaymentViewController(
            account: session.account,
            transaction: transaction
        )
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension SendAndRequestViewContainer: ConfirmPaymentViewControllerDelegate {
    func didCompleted(transaction: SentTransaction, in viewController: ConfirmPaymentViewController) {
        viewController.navigationController?.popViewController(animated: true)
        sendViewController.clear()
        displaySuccess(
            title: "Sent! TransactionID: \(transaction.id)",
            message: ""
        )
    }
}
