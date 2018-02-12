// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class PreferencesControllerTests: XCTestCase {

    func testShowTokensOnStartDefault() {
        let controller = PreferencesController(userDefaults: .test)

        XCTAssertEqual(controller.get(for: .showTokensOnLaunch), false)
    }

    func testShowTokensOnStartDisable() {
        let controller = PreferencesController(userDefaults: .test)

        controller.set(value: false, for: .showTokensOnLaunch)

        XCTAssertEqual(controller.get(for: .showTokensOnLaunch), false)
    }
}
