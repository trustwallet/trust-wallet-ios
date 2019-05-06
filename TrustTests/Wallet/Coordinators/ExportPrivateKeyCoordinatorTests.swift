// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import IPOS

class ExportPrivateKeyCoordinatorTests: XCTestCase {
    
    func testInit() {
        let coordinator = ExportPrivateKeyCoordinator(
            privateKey: Data()
        )

        XCTAssertTrue(coordinator.rootViewController is ExportPrivateKeyViewConroller)
    }
}
