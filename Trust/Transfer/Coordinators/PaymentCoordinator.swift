// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol PaymentCoordinatorDelegate: class {
    func didCancel(in coordinator: PaymentCoordinator)
}

class PaymentCoordinator: Coordinator {

    let session: WalletSession
    weak var delegate: PaymentCoordinatorDelegate?

    let flow: PaymentFlow
    var coordinators: [Coordinator] = []

    let navigationController: UINavigationController

    lazy var requestViewController: RequestViewController = {
        return self.makeRequestViewController()
    }()

    lazy var transferType: TransferType = {
        switch self.flow {
        case .send(let type):
            return type
        case .request:
            return .ether(destination: .none)
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
    }

    func start() {
        switch flow {
        case .send(let type):
            let coordinator = SendCoordinator(
                transferType: type,
                navigationController: navigationController,
                session: session
            )
            coordinator.delegate = self
            coordinator.start()
            addCoordinator(coordinator)
        case .request:
            navigationController.viewControllers = [requestViewController]
        }
    }

    func makeRequestViewController() -> RequestViewController {
        let controller = RequestViewController(account: self.session.account)
        controller.navigationItem.titleView = BalanceTitleView.make(from: self.session)
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

    func cancel() {
        delegate?.didCancel(in: self)
    }
}

extension PaymentCoordinator: SendCoordinatorDelegate {
    func didCancel(in coordinator: SendCoordinator) {
        removeCoordinator(coordinator)
        cancel()
    }
}
