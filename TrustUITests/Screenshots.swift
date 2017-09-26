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
        XCUIApplication().tables/*@START_MENU_TOKEN@*/.textFields["ETH Amount"]/*[[".cells.textFields[\"ETH Amount\"]",".textFields[\"ETH Amount\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        snapshot("2SendRequest")
        app.navigationBars["Send ETH"].buttons["Cancel"].tap()

        snapshot("3Transactions")

        app.tables.buttons["Show my tokens"].tap()
        sleep(12)
        snapshot("4Tokens")
    }
}
