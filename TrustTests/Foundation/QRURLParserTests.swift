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

    func testJustAddressString2() {
        let address = "0x6973dbabeb06dd60f1c50ed688fe11e742bc123e"
        let result = QRURLParser.from(string: address)

        XCTAssertEqual(address, result?.address)
    }

    func testProtocolAndAddress() {
        let result = QRURLParser.from(string: "ethereum:0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c")

        XCTAssertEqual("ethereum", result?.protocolName)
    }

    func testEthereumAddress() {
        let result = QRURLParser.from(string: "ethereum:0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c")

        XCTAssertEqual("0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c", result?.address)
    }

    func testEthereumAddressWithValue() {
        let result = QRURLParser.from(string: "ethereum:0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c?value=1")

        XCTAssertEqual("0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c", result?.address)
    }

    func testOMGAddress() {
        let result = QRURLParser.from(string: "omg:0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c")

        XCTAssertEqual("omg", result?.protocolName)
        XCTAssertEqual("0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c", result?.address)
    }

    func testBancorAddress() {
        let result = QRURLParser.from(string: "bancor:0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c")

        XCTAssertEqual("bancor", result?.protocolName)
        XCTAssertEqual("0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c", result?.address)
    }

    func testParseData() {
        let result = QRURLParser.from(string: "ethereum:0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c?data=0x123")

        XCTAssertEqual("ethereum", result?.protocolName)
        XCTAssertEqual(1, result?.params.count)
        XCTAssertEqual("0x123", result?.params["data"])
    }
}
