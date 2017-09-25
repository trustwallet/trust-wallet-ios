// Copyright SIX DAY LLC, Inc. All rights reserved.

import XCTest

class Screenshots: XCTestCase {
        
    override func setUp() {
        super.setUp()
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    func testMakeScreenshots() {

        let app = XCUIApplication()

        snapshot("0Launch")

        app.buttons["GET STARTED"].tap()

        snapshot("1Create Wallet")

        app.tables.staticTexts["Demo"].tap()

        snapshot("3Transactions")

        app.buttons["Send"].tap()

        snapshot("2SendAndReceive")

        app.navigationBars["Send ETH"].buttons["Cancel"].tap()

        app.tables.buttons["Show my tokens"].tap()

        sleep(12)

        snapshot("4Tokens")
    }
}
