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

        app.buttons["IMPORT WALLET"].tap()

        snapshot("3ImportWallet")
        sleep(6)

        app.buttons["Send"].tap()
        app.tables.textFields["ETH Amount"].tap()

        snapshot("1SendRequest")

        app.navigationBars["Send ETH"].buttons["Cancel"].tap()

        snapshot("4Transactions")

        app.tabBars.buttons["Tokens"].tap()
        sleep(8)
        snapshot("2Tokens")
    }
}
