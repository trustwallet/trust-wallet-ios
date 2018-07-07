// Copyright DApps Platform Inc. All rights reserved.

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

        sleep(23)

        snapshot("1Tokens")

        app.tabBars.buttons.element(boundBy: 2).tap()

        snapshot("4Transactions")

        app.tabBars.buttons.element(boundBy: 0).tap()

        snapshot("2Browser")
    }
}
