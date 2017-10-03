// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol SettingsCoordinatorDelegate: class {
    func didCancel(in coordinator: SettingsCoordinator)
    func didUpdate(action: SettingsAction, in coordinator: SettingsCoordinator)
}

class SettingsCoordinator {

    let navigationController: UINavigationController
    weak var delegate: SettingsCoordinatorDelegate?

    lazy var exportCoordinator: ExportCoordinator = {
        return ExportCoordinator(navigationController: self.rootNavigationController)
    }()

    lazy var rootNavigationController: UINavigationController = {
        let controller = self.makeSettingsController()
        let nav = NavigationController(rootViewController: controller)
        return nav
    }()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        navigationController.present(rootNavigationController, animated: true, completion: nil)
    }

    private func makeSettingsController() -> SettingsViewController {
        let controller = SettingsViewController()
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        controller.delegate = self
        return controller
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }

    @objc func export() {
        exportCoordinator.start()
        exportCoordinator.delegate = self
    }
}

extension SettingsCoordinator: SettingsViewControllerDelegate {
    func didAction(action: SettingsAction, in viewController: SettingsViewController) {
        switch action {
        case .exportPrivateKey:
            export()
        case .RPCServer: break
        }
        delegate?.didUpdate(action: action, in: self)
    }
}

extension SettingsCoordinator: ExportCoordinatorDelegate {
    func didFinish(in coordinator: ExportCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
    }

    func didCancel(in coordinator: ExportCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
    }
}
