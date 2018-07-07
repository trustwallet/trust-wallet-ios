// Copyright DApps Platform Inc. All rights reserved.

@testable import Trust
import XCTest

class StringFormatterTest: XCTestCase {
    let stringFormatter = StringFormatter()
    func testDoubleToStingFormatter() {
        XCTAssertEqual(stringFormatter.formatter(for: 0.00001), "0.000010")
        XCTAssertEqual(stringFormatter.formatter(for: 0.1234, with: 2), "0.12")
        XCTAssertEqual(stringFormatter.formatter(for: 1234.4321, with: 2), "1234.43")
    }
    func testDecimalToStingFormatter() {
        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        XCTAssertEqual(stringFormatter.token(with: 10000000000000.1234, and: 0), "10000000000000")
        XCTAssertEqual(stringFormatter.token(with: 1.1234, and: 0), "1")
        XCTAssertEqual(stringFormatter.token(with: 0.1234, and: 1), "0\(decimalSeparator)1")
        XCTAssertEqual(stringFormatter.token(with: 100000001.1234, and: 2), "100000001\(decimalSeparator)12")
        XCTAssertEqual(stringFormatter.token(with: 10.298234132231254, and: 8), "10\(decimalSeparator)29823413")
    }
}

