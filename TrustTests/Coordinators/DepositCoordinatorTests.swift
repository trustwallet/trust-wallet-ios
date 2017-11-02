// Copyright SIX DAY LLC. All rights reserved.

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

        XCTAssertTrue(coordinator.navigationController.presentedViewController is SFSafariViewController)
    }
}
