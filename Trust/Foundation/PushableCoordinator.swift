// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

typealias RootCoordinator = Coordinator & RootViewControllerProvider

protocol PushableCoordinator: RootViewControllerProvider {
    func pushCoordinator(_ coordinator: RootCoordinator)
    func popCoordinator(_ coordinator: RootCoordinator)
}

extension PushableCoordinator where Self: RootCoordinator {
    func pushCoordinator(_ coordinator: RootCoordinator) {
        if let presentedNVC = providedRootController.presentedViewController as? UINavigationController {
            addCoordinator(coordinator)
            presentedNVC.pushViewController(coordinator.providedRootController, animated: true)
        } else {
            guard let nvc = providedRootController.navigationController else {
                return
            }
            addCoordinator(coordinator)
            nvc.pushViewController(coordinator.providedRootController, animated: true)
        }
    }
    func popCoordinator(_ coordinator: RootCoordinator) {
        if let presentedNVC = providedRootController.presentedViewController as? UINavigationController {
            presentedNVC.popToViewController(coordinator.providedRootController, animated: true)
            removeCoordinator(coordinator)
        } else {
            guard let nvc = providedRootController.navigationController else {
                return
            }
            nvc.popViewController(animated: true)
            removeCoordinator(coordinator)
        }
    }
}
