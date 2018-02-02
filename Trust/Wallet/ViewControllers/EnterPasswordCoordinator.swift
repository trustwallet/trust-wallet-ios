// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore

protocol EnterPasswordCoordinatorDelegate: class {
    func didEnterPassword(password: String, account: Account, in coordinator: EnterPasswordCoordinator)
    func didCancel(in coordinator: EnterPasswordCoordinator)
}

class EnterPasswordCoordinator: Coordinator {
    var coordinators: [Coordinator] = []

    weak var delegate: EnterPasswordCoordinatorDelegate?

    lazy var enterPasswordController: EnterPasswordViewController = {
        let controller = EnterPasswordViewController(account: account)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        controller.delegate = self
        return controller
    }()
    let navigationController: UINavigationController
    private let account: Account

    init(
        navigationController: UINavigationController = UINavigationController(),
        account: Account
    ) {
        self.navigationController = navigationController
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
