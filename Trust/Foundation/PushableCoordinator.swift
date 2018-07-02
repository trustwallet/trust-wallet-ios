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
        if let presentedNVC = rootViewController.presentedViewController as? UINavigationController {
            addCoordinator(coordinator)
            coordinator.rootViewController.hidesBottomBarWhenPushed = tabBarHidden
            presentedNVC.setNavigationBarHidden(navigationBarHidden, animated: false)
            presentedNVC.pushViewController(coordinator.rootViewController, animated: true)
        } else {
            guard let nvc = rootViewController.navigationController else {
                return
            }
            addCoordinator(coordinator)
            coordinator.rootViewController.hidesBottomBarWhenPushed = tabBarHidden
            nvc.setNavigationBarHidden(navigationBarHidden, animated: false)
            nvc.pushViewController(coordinator.rootViewController, animated: true)
        }
    }
    func popCoordinator(_ coordinator: RootCoordinator, navigationBarHidden: Bool = false) {
        if let presentedNVC = rootViewController.presentedViewController as? UINavigationController {
            presentedNVC.setNavigationBarHidden(navigationBarHidden, animated: false)
            presentedNVC.popViewController(animated: true)
            removeCoordinator(coordinator)
        } else {
            guard let nvc = rootViewController.navigationController else {
                return
            }
            nvc.setNavigationBarHidden(navigationBarHidden, animated: false)
            nvc.popViewController(animated: true)
            removeCoordinator(coordinator)
        }
    }
}
