// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

typealias RootCoordinator = Coordinator & RootViewControllerProvider

protocol PushableCoordinator: RootViewControllerProvider {
    func pushCoordinator(_ coordinator: RootCoordinator, navigationBarHidden: Bool, tabBarHidden: Bool)
    func popCoordinator(_ coordinator: RootCoordinator, navigationBarHidden: Bool)
}

extension PushableCoordinator where Self: RootCoordinator {
    func pushCoordinator(_ coordinator: RootCoordinator, navigationBarHidden: Bool = true, tabBarHidden: Bool = false) {
        if let presentedNVC = providedRootController.presentedViewController as? UINavigationController {
            addCoordinator(coordinator)
            coordinator.providedRootController.hidesBottomBarWhenPushed = tabBarHidden
            presentedNVC.setNavigationBarHidden(navigationBarHidden, animated: false)
            presentedNVC.pushViewController(coordinator.providedRootController, animated: true)
        } else {
            guard let nvc = providedRootController.navigationController else {
                return
            }
            addCoordinator(coordinator)
            coordinator.providedRootController.hidesBottomBarWhenPushed = tabBarHidden
            nvc.setNavigationBarHidden(navigationBarHidden, animated: false)
            nvc.pushViewController(coordinator.providedRootController, animated: true)
        }
    }
    func popCoordinator(_ coordinator: RootCoordinator, navigationBarHidden: Bool = false) {
        if let presentedNVC = providedRootController.presentedViewController as? UINavigationController {
            presentedNVC.setNavigationBarHidden(navigationBarHidden, animated: false)
            presentedNVC.popViewController(animated: true)
            removeCoordinator(coordinator)
        } else {
            guard let nvc = providedRootController.navigationController else {
                return
            }
            nvc.setNavigationBarHidden(navigationBarHidden, animated: false)
            nvc.popViewController(animated: true)
            removeCoordinator(coordinator)
        }
    }
}
