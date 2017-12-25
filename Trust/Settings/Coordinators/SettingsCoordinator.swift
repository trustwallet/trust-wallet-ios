// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol SettingsCoordinatorDelegate: class {
    func didUpdate(action: SettingsAction, in coordinator: SettingsCoordinator)
}

class SettingsCoordinator: Coordinator {

    let navigationController: UINavigationController
    let keystore: Keystore
    weak var delegate: SettingsCoordinatorDelegate?

    let pushNotificationsRegistrar = PushNotificationsRegistrar()
    var coordinators: [Coordinator] = []

    lazy var rootViewController: SettingsViewController = {
        let controller = SettingsViewController()
        controller.delegate = self
        controller.modalPresentationStyle = .pageSheet
        return controller
    }()

    init(
        navigationController: UINavigationController = NavigationController(),
        keystore: Keystore
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.keystore = keystore
    }

    func start() {
        navigationController.viewControllers = [rootViewController]
    }
}

extension SettingsCoordinator: SettingsViewControllerDelegate {
    func didAction(action: SettingsAction, in viewController: SettingsViewController) {
        switch action {
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
