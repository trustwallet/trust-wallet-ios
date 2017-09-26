// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class WalletCoordinatorTests: XCTestCase {
    
    func testStart() {
        let coordinator = WalletCoordinator(
            rootNavigationController: FakeNavigationController()
        )

        coordinator.start()

        XCTAssertTrue(coordinator.navigationViewController.viewControllers[0] is CreateWalletViewController)
    }

    func testShowCreateWallet() {
        let coordinator = WalletCoordinator(
            rootNavigationController: FakeNavigationController()
        )

        coordinator.showCreateWallet()

        XCTAssertTrue(coordinator.navigationViewController.viewControllers[0] is CreateWalletViewController)
    }

    func testShowImportWallet() {
        let coordinator = WalletCoordinator(
            rootNavigationController: FakeNavigationController()
        )

        coordinator.showImportWallet()

        XCTAssertTrue(coordinator.navigationViewController.viewControllers[0] is ImportWalletViewController)
    }
}
