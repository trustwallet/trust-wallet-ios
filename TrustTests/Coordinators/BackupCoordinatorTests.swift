// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class BackupCoordinatorTests: XCTestCase {
    
    func testStart() {
        let coordinator = BackupCoordinator(
            navigationController: FakeNavigationController(),
            account: .make()
        )
        coordinator.start()

        XCTAssertTrue(coordinator.navigationController.presentedViewController is UIAlertController)
    }
}
