// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class PreferencesControllerTests: XCTestCase {

    func testDefaultValues() {
        let controller = PreferencesController(userDefaults: .test)

        XCTAssertEqual(controller.get(for: .airdropNotifications), false)
    }
}
