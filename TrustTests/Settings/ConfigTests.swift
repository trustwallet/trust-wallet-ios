// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust

class ConfigTests: XCTestCase {
        
    func testChainIDDefault() {
        var config: Config = .make()

        XCTAssertEqual(1, config.chainID)
        XCTAssertEqual(.main, config.server)
    }

    func testChangeChainID() {
        var config: Config = .make()

        XCTAssertEqual(1, config.chainID)

        config.chainID = 42

        XCTAssertEqual(42, config.chainID)
        XCTAssertEqual(.kovan, config.server)
    }

    func testTestDefaultisCryptoPrimaryCurrency() {
        var config: Config = .make()

        XCTAssertEqual(false, config.isCryptoPrimaryCurrency)
    }
    
    func testTestNetworkWarningOff() {
        var config: Config = .make()
        
        XCTAssertFalse(config.testNetworkWarningOff)
        
        config.testNetworkWarningOff = true
        
        XCTAssertTrue(config.testNetworkWarningOff)
    }
}

