// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class LockEnterPasscodeCoordinatorTest: XCTestCase {
    func testStart() {
        let viewModel = LockEnterPasscodeViewModel()
        let fakeLock = FakeLockProtocol()
        let coordinator = LockEnterPasscodeCoordinator(model: viewModel, lock: fakeLock)
        XCTAssertFalse(coordinator.protectionWasShown)
        coordinator.start()
        XCTAssertTrue(coordinator.protectionWasShown)
    }
    func testStop() {
        let viewModel = LockEnterPasscodeViewModel()
        let fakeLock = FakeLockProtocol()
        let coordinator = LockEnterPasscodeCoordinator(model: viewModel, lock: fakeLock)
        XCTAssertFalse(coordinator.protectionWasShown)
        coordinator.start()
        XCTAssertTrue(coordinator.protectionWasShown)
        coordinator.stop()
    }
    func testDisableLock() {
        let viewModel = LockEnterPasscodeViewModel()
        let fakeLock = FakeLockProtocol()
        fakeLock.passcodeSet = false 
        let coordinator = LockEnterPasscodeCoordinator(model: viewModel, lock: fakeLock)
        XCTAssertFalse(coordinator.protectionWasShown)
        coordinator.start()
        XCTAssertFalse(coordinator.protectionWasShown)
    }
}
