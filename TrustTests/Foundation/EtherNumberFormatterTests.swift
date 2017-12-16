// Copyright SIX DAY LLC. All rights reserved.

import BigInt
@testable import Trust
import XCTest

class EtherNumberFormatterTests: XCTestCase {
    let fullFormatter = EtherNumberFormatter(locale: Locale(identifier: "en_US_POSIX"))
    let shortFormatter: EtherNumberFormatter = {
        var formatter = EtherNumberFormatter(locale: Locale(identifier: "en_US_POSIX"))
        formatter.maximumFractionDigits = 3
        return formatter
    }()

    func testZero() {
        XCTAssertEqual(fullFormatter.string(from: BigInt(0)), "0")
        XCTAssertEqual(shortFormatter.string(from: BigInt(0)), "0")
    }

    func testSmall() {
        XCTAssertEqual(fullFormatter.string(from: BigInt(1)), "0.000000000000000001")
        XCTAssertEqual(shortFormatter.string(from: BigInt(1)), "0")
    }

    func testLarge() {
        XCTAssertEqual(fullFormatter.string(from: BigInt("1000000000000000000"), units: .wei), "1,000,000,000,000,000,000")
        XCTAssertEqual(fullFormatter.string(from: BigInt("100000000000000000"), units: .wei), "100,000,000,000,000,000")
        XCTAssertEqual(fullFormatter.string(from: BigInt("10000000000000000"), units: .wei), "10,000,000,000,000,000")
    }

    func testMinimumFractionDigits() {
        let formatter: EtherNumberFormatter = {
            let formatter = EtherNumberFormatter(locale: Locale(identifier: "en_US_POSIX"))
            formatter.minimumFractionDigits = 3
            formatter.maximumFractionDigits = 3
            return formatter
        }()
        XCTAssertEqual(formatter.string(from: BigInt(1)), "0.000")
    }

    func testDigits() {
        let number = BigInt("1234567890123456789012345678901")!
        XCTAssertEqual(fullFormatter.string(from: number), "1,234,567,890,123.456789012345678901")
        XCTAssertEqual(shortFormatter.string(from: number), "1,234,567,890,123.4567")
    }

    func testDigits2() {
        let number = BigInt("819947500000000000")!
        XCTAssertEqual(shortFormatter.string(from: number), "0.8199")
    }

    func testNoFraction() {
        let formatter: EtherNumberFormatter = {
            let formatter = EtherNumberFormatter(locale: Locale(identifier: "en_US_POSIX"))
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 0
            return formatter
        }()
        let number = BigInt("1000000000000000")!
        XCTAssertEqual(formatter.string(from: number), "0")
    }

    func testNegative() {
        let number = BigInt("-437258644730000000000")!
        XCTAssertEqual(fullFormatter.string(from: number), "-437.25864473")
        XCTAssertEqual(shortFormatter.string(from: number), "-437.2586")
    }

    func testRound() {
        let number = BigInt("123456789012345678901")!
        XCTAssertEqual(shortFormatter.string(from: number), "123.4567")
    }

    func testRoundNegative() {
        let number = BigInt("-123456789012345678901")!
        XCTAssertEqual(shortFormatter.string(from: number), "-123.4567")
    }

    func testDecimals() {
        let number = BigInt("987654321")!
        XCTAssertEqual(shortFormatter.string(from: number, decimals: 4), "98,765.4321")
    }

    func testFractionalToNumber() {
        let input = "0.123456789012345678"
        XCTAssertEqual(fullFormatter.number(from: input)?.description, "123456789012345678")
    }

    func testLargeNumber() {
        let input = "1234567890123456789012345678901.123456789012345678"
        XCTAssertEqual(fullFormatter.number(from: input)?.description, "1234567890123456789012345678901123456789012345678")
    }

    func testUnrepresentableNumber() {
        let input = "0.123456789012345678901"
        XCTAssertNil(fullFormatter.number(from: input))
    }

    func testInvalidNumber() {
        let input = "A0.190268247.487754"
        XCTAssertNil(fullFormatter.number(from: input))
    }
}
