// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Geth
import XCTest
@testable import Trust

class BigIntTests: XCTestCase {
    func testGethBigIntToBigInt() {
        let string = "1000000000000000000000000000"
        let geth = GethNewBigInt(0)!
        geth.setString(string, base: 10)
        let bigInt = BigInt(geth)
        XCTAssertEqual(bigInt.description, string)
    }

    func testGethBigIntToBigIntNegative() {
        let geth = GethNewBigInt(-1)!
        let bigInt = BigInt(geth)
        XCTAssertEqual(bigInt, -1)
    }

    func testBigIntToGethBigInt() {
        let string = "1000000000000000000000000000"
        let bigInt = BigInt(string)!
        let geth = bigInt.gethBigInt
        XCTAssertEqual(geth.string(), string)
    }

    func testBigIntToGethBigIntNegative() {
        let bigInt = BigInt(-1)
        let geth = bigInt.gethBigInt
        XCTAssertEqual(geth.getInt64(), -1)
    }
}
