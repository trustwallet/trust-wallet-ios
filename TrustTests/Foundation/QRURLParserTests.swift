// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class QRURLParserTests: XCTestCase {
    
    func testEmptyString() {
        let result = QRURLParser.from(string: "")

        XCTAssertNil(result)
    }

    func testJustAddressString() {
        let address = "0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c"
        let result = QRURLParser.from(string: address)

        XCTAssertEqual(address, result?.address)
    }

    func testProtocolAndAddress() {
        let result = QRURLParser.from(string: "ethereum:0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c")

        XCTAssertEqual("ethereum", result?.protocolName)
    }

    func testAddress() {
        let result = QRURLParser.from(string: "ethereum:0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c")

        XCTAssertEqual("0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c", result?.address)
    }
}
