// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust


class SplashCoordinatorTests: XCTestCase {
    func testStart() {
        let window = UIWindow()
        let coordinator = SplashCoordinator(window: window)
        coordinator.start()
        XCTAssertFalse(window.isHidden)
        XCTAssertNotNil(window.subviews.first)
    }
    func testStop() {
        let window = UIWindow()
        let coordinator = SplashCoordinator(window: window)
        coordinator.start()
        coordinator.stop()
        XCTAssertNil(window.subviews.first)
    }
}
