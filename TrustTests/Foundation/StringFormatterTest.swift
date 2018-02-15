// Copyright SIX DAY LLC. All rights reserved.

@testable import Trust
import XCTest

class StringFormatterTest: XCTestCase {
    let stringFormatter = StringFormatter()
    func testStringFormatter() {
        XCTAssertEqual(stringFormatter.formatter(for: 0.00001), "0.000010")
        XCTAssertEqual(stringFormatter.formatter(for: 0.1234, with: 2), "0.12")
        XCTAssertEqual(stringFormatter.token(with: 0.1234, and: 1), "0.1")
        XCTAssertEqual(stringFormatter.token(with: 1.1234, and: 0), "1")
    }
}
