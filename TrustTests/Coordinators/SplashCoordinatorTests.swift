// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import IPOS


class SplashCoordinatorTests: XCTestCase {
    func testStart() {
        let window = UIWindow()
        let coordinator = SplashCoordinator(window: window)
        coordinator.start()
        XCTAssertFalse(window.isHidden)
    }
    func testStop() {
        let window = UIWindow()
        let coordinator = SplashCoordinator(window: window)
        coordinator.start()
        coordinator.stop()
        XCTAssertTrue(window.isHidden)
    }
}
