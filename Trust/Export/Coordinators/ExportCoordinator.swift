// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Result

protocol ExportCoordinatorDelegate: class {
    func didFinish(in coordinator: ExportCoordinator)
    func didCancel(in coordinator: ExportCoordinator)
}

class ExportCoordinator: Coordinator {

    let navigationController: UINavigationController
    weak var delegate: ExportCoordinatorDelegate?
    let keystore = EtherKeystore()
    var coordinators: [Coordinator] = []
    lazy var accountViewController: AccountsViewController = {
        let controller = AccountsViewController()
        controller.headerTitle = "Select Account to Backup"
        controller.delegate = self
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        return controller
    }()

    init(
        navigationController: UINavigationController = NavigationController()
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
    }

    func start() {
        navigationController.viewControllers = [accountViewController]
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }

    func finish() {
        delegate?.didFinish(in: self)
    }

    func export(for account: Account) {
        let coordinator = BackupCoordinator(
            navigationController: navigationController,
            account: account
        )
        addCoordinator(coordinator)
        coordinator.start()
    }
}

extension ExportCoordinator: AccountsViewControllerDelegate {
    func didSelectAccount(account: Account, in viewController: AccountsViewController) {
        export(for: account)
    }

    func didDeleteAccount(account: Account, in viewController: AccountsViewController) {

    }
}

extension ExportCoordinator: BackupCoordinatorDelegate {
    func didFinish(account: Account, in coordinator: BackupCoordinator) {
        removeCoordinator(coordinator)
        delegate?.didFinish(in: self)
    }

    func didCancel(coordinator: BackupCoordinator) {
        removeCoordinator(coordinator)
        delegate?.didCancel(in: self)
    }
}
