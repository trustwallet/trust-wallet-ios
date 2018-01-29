// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class BrowserURLParserTests: XCTestCase {
    
//    func testQueryReturnsSearchEngineURL() {
//        let parser = BrowserURLParser()
//        let query = "1"
//        let result = parser.url(from: query)
//        let expetected = parser.searchURL + query
//
//        XCTAssertEqual(expetected, result?.absoluteString)
//    }

    func testParseDomain() {
        let parser = BrowserURLParser()
        let query = "trustwalletapp.com"
        let result = parser.url(from: query)

        XCTAssertEqual("http://" + query, result?.absoluteString)
    }

    func testParseHttp() {
        let parser = BrowserURLParser()
        let query = "http://trustwalletapp.com"
        let result = parser.url(from: query)

        XCTAssertEqual(query, result?.absoluteString)
    }

    func testParseHttps() {
        let parser = BrowserURLParser()
        let query = "https://trustwalletapp.com"
        let result = parser.url(from: query)

        XCTAssertEqual(query, result?.absoluteString)
    }

    func testSearchURL() {
        let parser = BrowserURLParser()
        let query = "test"
        let result = parser.searchURL(for: query)
        let expeted = parser.searchURL + query

        XCTAssertEqual(expeted, result?.absoluteString)
    }
}
