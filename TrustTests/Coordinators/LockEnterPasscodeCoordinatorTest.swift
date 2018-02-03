// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class LockEnterPasscodeCoordinatorTest: XCTestCase {
    func testStart() {
        let window = UIWindow()
        let viewModel = LockEnterPasscodeViewModel()
        let fakeLock = FakeLockProtocol()
        let coordinator = LockEnterPasscodeCoordinator(window: window, model: viewModel, lock: fakeLock)
        XCTAssertFalse(coordinator.protectionWasShown)
        coordinator.start()
        XCTAssertTrue(coordinator.protectionWasShown)
        XCTAssertTrue(window.rootViewController is LockEnterPasscodeViewController)
    }
    func testStop() {
        let window = UIWindow()
        let viewModel = LockEnterPasscodeViewModel()
        let fakeLock = FakeLockProtocol()
        let coordinator = LockEnterPasscodeCoordinator(window: window, model: viewModel, lock: fakeLock)
        XCTAssertFalse(coordinator.protectionWasShown)
        coordinator.start()
        XCTAssertTrue(coordinator.protectionWasShown)
        coordinator.stop()
        XCTAssertTrue(window.isHidden)
    }
    func testDisableLock() {
        let window = UIWindow()
        let viewModel = LockEnterPasscodeViewModel()
        let fakeLock = FakeLockProtocol()
        fakeLock.passcodeSet = false 
        let coordinator = LockEnterPasscodeCoordinator(window: window, model: viewModel, lock: fakeLock)
        XCTAssertFalse(coordinator.protectionWasShown)
        coordinator.start()
        XCTAssertFalse(coordinator.protectionWasShown)
    }
}
