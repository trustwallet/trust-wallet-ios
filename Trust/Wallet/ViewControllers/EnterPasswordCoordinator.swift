// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustKeystore

protocol EnterPasswordCoordinatorDelegate: class {
    func didEnterPassword(password: String, account: Account, in coordinator: EnterPasswordCoordinator)
    func didCancel(in coordinator: EnterPasswordCoordinator)
}

final class EnterPasswordCoordinator: Coordinator {
    var coordinators: [Coordinator] = []

    weak var delegate: EnterPasswordCoordinatorDelegate?

    lazy var enterPasswordController: EnterPasswordViewController = {
        let controller = EnterPasswordViewController(account: account)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        controller.delegate = self
        return controller
    }()
    let navigationController: NavigationController
    private let account: Account

    init(
        navigationController: NavigationController = NavigationController(),
        account: Account
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.account = account
    }

    func start() {
        navigationController.viewControllers = [enterPasswordController]
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }
}

extension EnterPasswordCoordinator: EnterPasswordViewControllerDelegate {
    func didEnterPassword(password: String, for account: Account, in viewController: EnterPasswordViewController) {
        delegate?.didEnterPassword(password: password, account: account, in: self)
    }
}
