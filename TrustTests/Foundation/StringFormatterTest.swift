// Copyright SIX DAY LLC. All rights reserved.

@testable import Trust
import XCTest

class StringFormatterTest: XCTestCase {
    let stringFormatter = StringFormatter()
    func testStringFormatter() {
        XCTAssertEqual(stringFormatter.formatter(for: 0.00001), "0.000010")
        XCTAssertEqual(stringFormatter.formatter(for: 0.1234, with: 2), "0.12")
    }
}
