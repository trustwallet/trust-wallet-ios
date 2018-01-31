// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class LockEnterPasscodeCoordinatorTest: XCTestCase {
    func testStart() {
        let window = UIWindow()
        let viewModel = LockEnterPasscodeViewModel()
        let fakeLock = FakeLockProtocol()
        let coordinator = LockEnterPasscodeCoordinator(window: window, model: viewModel, lock: fakeLock)
        XCTAssertFalse(coordinator.passcodeViewIsActive)
        coordinator.start()
        XCTAssertTrue(coordinator.passcodeViewIsActive)
        XCTAssertTrue(window.rootViewController is LockEnterPasscodeViewController)
    }
    func testDismiss() {
        let window = UIWindow()
        let viewModel = LockEnterPasscodeViewModel()
        let fakeLock = FakeLockProtocol()
        let coordinator = LockEnterPasscodeCoordinator(window: window, model: viewModel, lock: fakeLock)
        XCTAssertFalse(coordinator.passcodeViewIsActive)
        coordinator.start()
        XCTAssertTrue(coordinator.passcodeViewIsActive)
        coordinator.dismiss()
        XCTAssertTrue(window.isHidden)
        XCTAssertFalse(coordinator.passcodeViewIsActive)
    }
}
