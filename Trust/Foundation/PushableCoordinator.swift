// Copyright SIX DAY LLC. All rights reserved.

import Foundation

typealias RootCoordinator = Coordinator & RootViewControllerProvider

protocol PushableCoordinator {
    func pushCoordinator(_ coordinator: RootCoordinator)
    func popCoordinator(_ coordinator: RootCoordinator)
}
