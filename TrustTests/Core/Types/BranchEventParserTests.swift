// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust

class BranchEventParserTests: XCTestCase {
    
    func testOpenURL() {
        let result = BranchEventParser.from(params: [
            "event": "openURL" as AnyObject,
            "url": "https://trustwalletapp.com" as AnyObject
        ])

        let expectedEvent = BranchEvent.openURL(URL(string: "https://trustwalletapp.com")!)
        XCTAssertEqual(expectedEvent, result)
    }
}
