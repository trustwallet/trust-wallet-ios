// Copyright SIX DAY LLC. All rights reserved.

import BigInt
@testable import Trust
import XCTest

class RLPTests: XCTestCase {
    func testStrings() {
        XCTAssertEqual(RLP.encode("")!.hex, "80")
        XCTAssertEqual(RLP.encode("dog")!.hex, "83646f67")
    }

    func testIntegers() {
        XCTAssertEqual(RLP.encode(0)!.hex, "80")
        XCTAssertEqual(RLP.encode(127)!.hex, "7f")
        XCTAssertEqual(RLP.encode(128)!.hex, "8180")
        XCTAssertEqual(RLP.encode(256)!.hex, "820100")
        XCTAssertEqual(RLP.encode(1024)!.hex, "820400")
        XCTAssertEqual(RLP.encode(0xffffff)!.hex, "83ffffff")
        XCTAssertEqual(RLP.encode(0xffffffff)!.hex, "84ffffffff")
        XCTAssertEqual(RLP.encode(0xffffffffffffff)!.hex, "87ffffffffffffff")
    }

    func testBigInts() {
        XCTAssertEqual(RLP.encode(BigInt(0))!.hex, "80")
        XCTAssertEqual(RLP.encode(BigInt(1))!.hex, "01")
        XCTAssertEqual(RLP.encode(BigInt(127))!.hex, "7f")
        XCTAssertEqual(RLP.encode(BigInt(128))!.hex, "8180")
        XCTAssertEqual(RLP.encode(BigInt(256))!.hex, "820100")
        XCTAssertEqual(RLP.encode(BigInt(1024))!.hex, "820400")
        XCTAssertEqual(RLP.encode(BigInt(0xffffff))!.hex, "83ffffff")
        XCTAssertEqual(RLP.encode(BigInt(0xffffffff))!.hex, "84ffffffff")
        XCTAssertEqual(RLP.encode(BigInt(0xffffffffffffff))!.hex, "87ffffffffffffff")
        XCTAssertEqual(
            RLP.encode(BigInt("102030405060708090a0b0c0d0e0f2", radix: 16)!)!.hex,
            "8f102030405060708090a0b0c0d0e0f2"
        )
        XCTAssertEqual(
            RLP.encode(BigInt("0100020003000400050006000700080009000a000b000c000d000e01", radix: 16)!)!.hex,
            "9c0100020003000400050006000700080009000a000b000c000d000e01"
        )
        XCTAssertEqual(
            RLP.encode(BigInt("010000000000000000000000000000000000000000000000000000000000000000", radix: 16)!)!.hex,
            "a1010000000000000000000000000000000000000000000000000000000000000000"
        )
        XCTAssertNil(RLP.encode(BigInt("-1")!))
    }

    func testLists() {
        XCTAssertEqual(RLP.encode([])!.hex, "c0")
        XCTAssertEqual(RLP.encode([1, 2, 3])!.hex, "c3010203")
        XCTAssertEqual(RLP.encode(["cat", "dog"])!.hex, "c88363617483646f67")
        XCTAssertEqual(RLP.encode([ [], [[]], [ [], [[]] ] ])!.hex, "c7c0c1c0c3c0c1c0")
        XCTAssertEqual(RLP.encode([1, 0xffffff, [4, 5, 5], "abc"])!.hex, "cd0183ffffffc304050583616263")
        let encoded = RLP.encode(Array<Int>(repeating: 0, count: 1024))!
        print(encoded.hex)
        XCTAssert(encoded.hex.hasPrefix("f90400"))
    }
}
