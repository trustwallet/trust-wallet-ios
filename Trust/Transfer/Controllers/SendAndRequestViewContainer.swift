// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol SendAndRequestViewContainerDelegate: class {
    func didCreatePendingTransaction(_ transaction: SentTransaction, in viewController: SendAndRequestViewContainer)
}

class SendAndRequestViewContainer: UIViewController {

    var flow: PaymentFlow {
        didSet {
            updateTo(flow: flow)
        }
    }
    let account: Account
    weak var delegate: SendAndRequestViewContainerDelegate?

    lazy var sendController: SendViewController = {
        let controller = SendViewController(account: self.account)
        controller.delegate = self
        return controller
    }()

    lazy var requestController: RequestViewController = {
        let controller = RequestViewController(account: self.account)
        return controller
    }()

    lazy var  segment: UISegmentedControl = {
        let segment =  UISegmentedControl(frame: .zero)
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.insertSegment(withTitle: NSLocalizedString("Generic.Send", value: "Send", comment: ""), at: 0, animated: false)
        segment.insertSegment(withTitle: NSLocalizedString("Generic.Request", value: "Request", comment: ""), at: 1, animated: false)
        segment.addTarget(self, action: #selector(segmentChange), for: .valueChanged)
        return segment
    }()

    var configuration = TransactionConfiguration() {
        didSet {
            sendController.configuration = configuration
        }
    }

    init(flow: PaymentFlow, account: Account) {
        self.flow = flow
        self.account = account
        super.init(nibName: nil, bundle: nil)

        navigationItem.titleView = segment
        view.backgroundColor = .white

        if case let .send(destination) = flow {
            sendController.addressRow?.value = destination?.address
            sendController.addressRow?.updateCell()
        }

        updateTo(flow: flow)
    }

    func segmentChange() {
        flow = PaymentFlow(
            selectedSegmentIndex: segment.selectedSegmentIndex
        )
    }

    func updateTo(flow: PaymentFlow) {
        switch flow {
        case .send:
            add(asChildViewController: sendController)
            remove(asChildViewController: requestController)
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: NSLocalizedString("Generic.Send", value: "Send", comment: ""),
                style: .done,
                target: sendController,
                action: #selector(SendViewController.send)
            )
        case .request:
            add(asChildViewController: requestController)
            remove(asChildViewController: sendController)
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        }
        segment.selectedSegmentIndex = flow.selectedSegmentIndex
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
        let address = account.address.address
        let activityViewController = UIActivityViewController(
            activityItems: [
                "My Ethereum address is: \(address)",
            ],
            applicationActivities: nil
        )
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

extension PaymentFlow {
    init(selectedSegmentIndex: Int) {
        switch selectedSegmentIndex {
        case 0: self = .send(destination: .none)
        case 1: self = .request
        default: self = .send(destination: .none)
        }
    }

    var selectedSegmentIndex: Int {
        switch self {
        case .send: return 0
        case .request: return 1
        }
    }
}
