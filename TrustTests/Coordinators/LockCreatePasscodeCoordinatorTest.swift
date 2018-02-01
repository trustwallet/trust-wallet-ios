// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class LockCreatePasscodeCoordinatorTest: XCTestCase {
    func testStart() {
        let navigationController = UINavigationController()
        let coordinator = LockCreatePasscodeCoordinator(navigationController: navigationController, model: LockCreatePasscodeViewModel())
        coordinator.start()
        XCTAssertTrue(navigationController.viewControllers.first is LockCreatePasscodeViewController)
    }
    func testStop() {
        let navigationController = UINavigationController()
        let coordinator = LockCreatePasscodeCoordinator(navigationController: navigationController, model: LockCreatePasscodeViewModel())
        coordinator.start()
        XCTAssertTrue(navigationController.viewControllers.first is LockCreatePasscodeViewController)
        coordinator.stop()
        XCTAssertNil(navigationController.presentedViewController)
    }
}
