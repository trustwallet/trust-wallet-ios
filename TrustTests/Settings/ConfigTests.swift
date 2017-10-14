// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class ConfigTests: XCTestCase {
        
    func testChainIDDefault() {
        let config = Config(defaults: .test)

        XCTAssertEqual(1, config.chainID)
        XCTAssertEqual(.main, config.server)
    }

    func testChangeChainID() {
        var config = Config(defaults: .test)

        XCTAssertEqual(1, config.chainID)

        config.chainID = 42

        XCTAssertEqual(42, config.chainID)
        XCTAssertEqual(.kovan, config.server)
    }

    func testTestDefaultisCryptoPrimaryCurrency() {
        let config = Config(defaults: .test)

        XCTAssertEqual(false, config.isCryptoPrimaryCurrency)
    }
}

