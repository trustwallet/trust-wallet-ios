// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust

class BrowserURLParserTests: XCTestCase {
    
    func testQueryReturnsSearchEngineURL() {
        let parser = BrowserURLParser()
        let query = "1"
        let result = parser.url(from: query)
        let expected = "https://\(parser.engine.host)/search?q=1"

        XCTAssertEqual(result?.absoluteString, expected)
    }

    func testEscapeQuery() {
        let parser = BrowserURLParser()
        let query = "1 2?a=b&c"
        let result = parser.url(from: query)
        let expected = "https://\(parser.engine.host)/search?q=1%202?a%3Db%26c"

        XCTAssertEqual(result?.absoluteString, expected)
    }

    func testParseDomain() {
        let parser = BrowserURLParser()
        let query = "trustwalletapp.com"
        let result = parser.url(from: query)

        XCTAssertEqual(result?.absoluteString, "http://trustwalletapp.com")
    }

    func testParseHttp() {
        let parser = BrowserURLParser()
        let string = "http://trustwalletapp.com"
        let result = parser.url(from: string)

        XCTAssertEqual(string, result?.absoluteString)
    }

    func testParseHttps() {
        let parser = BrowserURLParser()
        let string = "https://trustwalletapp.com"
        let result = parser.url(from: string)

        XCTAssertEqual(string, result?.absoluteString)
    }

    func testParseDomainWithPath() {
        let parser = BrowserURLParser()
        let string = "trustwalletapp.com/path?q=1"
        let result = parser.url(from: string)

        XCTAssertEqual(result?.absoluteString, "http://\(string)")
    }

    func testParseLongDomain() {
        let parser = BrowserURLParser()
        let string = "test.trustwalletapp.info"
        let result = parser.url(from: string)

        XCTAssertEqual(result?.absoluteString, "http://\(string)")
    }

    func testSearchURL() {
        let parser = BrowserURLParser()
        let query = "test"
        let result = parser.buildSearchURL(for: query)
        let expeted = "https://\(parser.engine.host)/search?q=test"

        XCTAssertEqual(result.absoluteString, expeted)
    }
}
