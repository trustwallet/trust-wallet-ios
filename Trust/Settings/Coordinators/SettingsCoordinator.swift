// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol SettingsCoordinatorDelegate: class {
    func didCancel(in coordinator: SettingsCoordinator)
    func didUpdate(action: SettingsAction, in coordinator: SettingsCoordinator)
}

class SettingsCoordinator: Coordinator {

    let navigationController: UINavigationController
    let keystore: Keystore
    weak var delegate: SettingsCoordinatorDelegate?

    let pushNotificationsRegistrar = PushNotificationsRegistrar()
    var coordinators: [Coordinator] = []

    init(
        navigationController: UINavigationController = NavigationController(),
        keystore: Keystore
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.keystore = keystore
    }

    func start() {
        navigationController.viewControllers = [makeSettingsController()]
    }

    private func makeSettingsController() -> SettingsViewController {
        let controller = SettingsViewController()
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismiss))
        controller.delegate = self
        controller.modalPresentationStyle = .pageSheet
        return controller
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }

    @objc func export(in viewController: UIViewController) {
        let coordinator = ExportCoordinator(keystore: keystore)
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
        viewController.present(coordinator.navigationController, animated: true, completion: nil)
    }
}

extension SettingsCoordinator: SettingsViewControllerDelegate {
    func didAction(action: SettingsAction, in viewController: SettingsViewController) {
        switch action {
        case .exportPrivateKey:
            export(in: viewController)
        case .RPCServer: break
        case .donate: break
        case .pushNotifications(let enabled):
            switch enabled {
            case true:
                pushNotificationsRegistrar.register()
            case false:
                pushNotificationsRegistrar.unregister()
            }
        }
        delegate?.didUpdate(action: action, in: self)
    }
}

extension SettingsCoordinator: ExportCoordinatorDelegate {
    func didFinish(in coordinator: ExportCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }

    func didCancel(in coordinator: ExportCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }
}
