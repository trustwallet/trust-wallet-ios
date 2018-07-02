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
        if let presentedNVC = rootViewController.presentedViewController as? UINavigationController {
            addCoordinator(coordinator)
            presentedNVC.pushViewController(coordinator.rootViewController, animated: true)
        } else {
            guard let nvc = rootViewController.navigationController else {
                return
            }
            addCoordinator(coordinator)
            nvc.pushViewController(coordinator.rootViewController, animated: true)
        }
    }
    func popCoordinator(_ coordinator: RootCoordinator) {
        if let presentedNVC = rootViewController.presentedViewController as? UINavigationController {
            presentedNVC.popToViewController(coordinator.rootViewController, animated: true)
            removeCoordinator(coordinator)
        } else {
            guard let nvc = rootViewController.navigationController else {
                return
            }
            nvc.popViewController(animated: true)
            removeCoordinator(coordinator)
        }
    }
}
