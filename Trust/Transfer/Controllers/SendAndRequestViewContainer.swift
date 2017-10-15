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

    lazy var sendButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(
            title: NSLocalizedString("Generic.Send", value: "Send", comment: ""),
            style: .done,
            target: self.sendViewController,
            action: #selector(SendViewController.send)
        )
    }()

    lazy var shareButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
    }()

    var configuration = TransactionConfiguration() {
        didSet {
            sendViewController.configuration = configuration
        }
    }

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
            navigationItem.rightBarButtonItem = sendButtonItem
        case .request:
            add(asChildViewController: requestController)
            remove(asChildViewController: sendViewController)
            navigationItem.rightBarButtonItem = shareButton
        }
    }

    @objc func openConfiguration() {
        let controller = TransactionConfigurationViewController(
            configuration: configuration
        )
        let nav = NavigationController(rootViewController: controller)
        controller.delegate = self
        present(nav, animated: true, completion: nil)
    }

    @objc func share() {
        let address = session.account.address.address
        let activityViewController = UIActivityViewController(
            activityItems: [
                NSLocalizedString("Send.MyEthereumAddressIs", value: "My Ethereum address is:", comment: "") + address,
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
    func didPressConfiguration(in viewController: SendViewController) {
        openConfiguration()
    }

    func didCreatePendingTransaction(_ transaction: SentTransaction, in viewController: SendViewController) {
        delegate?.didCreatePendingTransaction(transaction, in: self)
    }
}

extension SendAndRequestViewContainer: TransactionConfigurationViewControllerDelegate {
    func didUpdate(configuration: TransactionConfiguration, in viewController: TransactionConfigurationViewController) {
        self.configuration = configuration
        viewController.dismiss(animated: true, completion: nil)
    }
}
