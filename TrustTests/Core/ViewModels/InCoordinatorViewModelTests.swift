// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class InCoordinatorViewModelTests: XCTestCase {
    
    func testInitialTab() {
        let viewModel = InCoordinatorViewModel(config: .make())

        XCTAssertEqual(.transactions, viewModel.initialTab)
    }

    func testInitialTabWhenEnabledInPreferences() {
        let preferences: PreferencesController = .make()
        preferences.set(value: true, for: .showTokensOnLaunch)

        let viewModel = InCoordinatorViewModel(
            config: .make(),
            preferences: preferences
        )

        XCTAssertEqual(.tokens, viewModel.initialTab)
    }
}
