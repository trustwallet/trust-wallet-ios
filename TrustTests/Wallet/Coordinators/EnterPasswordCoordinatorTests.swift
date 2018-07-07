// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust

class EnterPasswordCoordinatorTests: XCTestCase {
    
    func testStart() {
        let coordinator = EnterPasswordCoordinator(account: .make())

        coordinator.start()

        XCTAssertTrue(coordinator.navigationController.viewControllers[0] is EnterPasswordViewController)
    }
}
