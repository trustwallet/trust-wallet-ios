// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol RequestCoordinatorDelegate: class {
    func didCancel(in coordinator: RequestCoordinator)
}

class RequestCoordinator: Coordinator {

    let session: WalletSession
    let navigationController: UINavigationController
    var coordinators: [Coordinator] = []
    weak var delegate: RequestCoordinatorDelegate?
    lazy var requestViewController: RequestViewController = {
        return self.makeRequestViewController()
    }()

    init(
        navigationController: UINavigationController = UINavigationController(),
        session: WalletSession
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.session = session
    }

    func start() {
        navigationController.viewControllers = [requestViewController]
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
}
