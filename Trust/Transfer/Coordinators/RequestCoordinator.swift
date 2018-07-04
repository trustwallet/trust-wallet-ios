// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol RequestCoordinatorDelegate: class {
    func didCancel(in coordinator: RequestCoordinator)
}

class RequestCoordinator: Coordinator {

    let session: WalletSession
    let navigationController: NavigationController
    var coordinators: [Coordinator] = []
    weak var delegate: RequestCoordinatorDelegate?
    lazy var requestViewController: RequestViewController = {
        return self.makeRequestViewController()
    }()
    private lazy var viewModel: RequestViewModel = {
        return .init(account: session.account.wallet, config: session.config, token: token)
    }()
    private let token: TokenObject

    init(
        navigationController: NavigationController = NavigationController(),
        session: WalletSession,
        token: TokenObject
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.session = session
        self.token = token
    }

    func start() {
        navigationController.viewControllers = [requestViewController]
    }

    func makeRequestViewController() -> RequestViewController {
        let controller = RequestViewController(viewModel: viewModel)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share(_:)))
        return controller
    }

    @objc func share(_ sender: UIBarButtonItem) {
        let items = [viewModel.shareMyAddressText, requestViewController.imageView.image as Any].compactMap { $0 }
        let activityViewController = UIActivityViewController.make(items: items)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        navigationController.present(activityViewController, animated: true, completion: nil)
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }
}
