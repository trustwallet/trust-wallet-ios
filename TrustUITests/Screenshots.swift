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

        app.buttons["import-wallet"].tap()

        snapshot("3ImportWallet")
        sleep(3)

        app.tabBars.buttons.element(boundBy: 1).tap()

        sleep(1)

        app.tabBars.buttons.element(boundBy: 0).tap()

        app.buttons["send-button"].tap()
        app.tables.textFields["amount-field"].tap()

        snapshot("1SendRequest")

        app.navigationBars.buttons.element(boundBy: 0).tap()

        snapshot("4Transactions")

        app.tabBars.buttons.element(boundBy: 1).tap()

        snapshot("2Tokens")
    }
}
