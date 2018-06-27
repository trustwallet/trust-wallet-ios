// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class ExportPrivateKeyCoordinatorTests: XCTestCase {
    
    func testStart() {
        let coordinator = ExportPrivateKeyCoordinator(
            privateKey: Data()
        )

        coordinator.start()

        XCTAssertTrue(coordinator.navigationController.viewControllers[0] is ExportPrivateKeyViewConroller)
    }
}
