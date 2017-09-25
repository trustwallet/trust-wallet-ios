// Copyright SIX DAY LLC, Inc. All rights reserved.

import XCTest

class Screenshots: XCTestCase {
        
    override func setUp() {
        super.setUp()
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    func testLaunch() {
        snapshot("0Launch")
    }
}
