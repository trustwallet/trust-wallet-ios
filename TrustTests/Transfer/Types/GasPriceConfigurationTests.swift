// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust
import BigInt

class GasPriceConfigurationTests: XCTestCase {
    
    func testDefault() {
        XCTAssertEqual(BigInt(24000000000), GasPriceConfiguration.default)
        XCTAssertEqual(BigInt(1000000000), GasPriceConfiguration.min)
        XCTAssertEqual(BigInt(100000000000), GasPriceConfiguration.max)
    }
}
