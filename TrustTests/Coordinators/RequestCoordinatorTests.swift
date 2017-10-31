// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class RequestCoordinatorTests: XCTestCase {

    func testRootViewController() {
        let coordinator = RequestCoordinator(
            navigationController: FakeNavigationController(),
            session: .make()
        )

        coordinator.start()

        XCTAssertTrue(coordinator.navigationController.viewControllers.first is RequestViewController)
    }
}

