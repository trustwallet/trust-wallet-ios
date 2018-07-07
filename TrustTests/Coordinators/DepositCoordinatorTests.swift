// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust
import SafariServices

class DepositCoordinatorTests: XCTestCase {
    
    func testStart() {
        let coordinator = DepositCoordinator(
            navigationController: FakeNavigationController(),
            account: .make()
        )

        coordinator.start()

        XCTAssertTrue(coordinator.navigationController.presentedViewController is UIAlertController)
    }

    func testDepositCoinbase() {
        let coordinator = DepositCoordinator(
            navigationController: FakeNavigationController(),
            account: .make()
        )

        coordinator.showCoinbase()

        XCTAssertTrue(coordinator.navigationController.presentedViewController is SFSafariViewController)
    }

    func testDepositShapeShift() {
        let coordinator = DepositCoordinator(
            navigationController: FakeNavigationController(),
            account: .make()
        )

        coordinator.showShapeShift()

        XCTAssertTrue(coordinator.navigationController.presentedViewController is SFSafariViewController)
    }
}
