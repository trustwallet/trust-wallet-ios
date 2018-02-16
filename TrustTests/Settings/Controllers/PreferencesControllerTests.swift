// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class PreferencesControllerTests: XCTestCase {

    func testDefaultValues() {
        let controller = PreferencesController(userDefaults: .test)

        XCTAssertEqual(controller.get(for: .showTokensOnLaunch), false)
        XCTAssertEqual(controller.get(for: .airdropNotifications), false)
    }

    func testShowTokensOnStartDisable() {
        let controller = PreferencesController(userDefaults: .test)

        controller.set(value: false, for: .showTokensOnLaunch)

        XCTAssertEqual(controller.get(for: .showTokensOnLaunch), false)
    }
}
