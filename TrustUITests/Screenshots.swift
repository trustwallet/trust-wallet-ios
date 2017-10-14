// Copyright SIX DAY LLC. All rights reserved.

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
        snapshot("1CreateWallet")
        sleep(4)
        app.navigationBars["New Wallet"].buttons["Demo"].tap()

        app.buttons["Send"].tap()
        app.tables.textFields["Amount"].tap()
        snapshot("2SendRequest")

        app.navigationBars["Trust.SendAndRequestViewContainer"].buttons["Cancel"].tap()

        snapshot("3Transactions")

        app.tables.buttons["Show my tokens"].tap()
        sleep(12)
        snapshot("4Tokens")
    }
}
