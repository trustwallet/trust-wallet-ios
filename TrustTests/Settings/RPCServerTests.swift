// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class RPCServerTests: XCTestCase {
    
    func testMainNetwork() {
        let server = RPCServer(chainID: 1)

        XCTAssertEqual(.main, server)
    }

    func testKovanNetwork() {
        let server = RPCServer(chainID: 42)

        XCTAssertEqual(.kovan, server)
    }

    func testRopstenNetwork() {
        let server = RPCServer(chainID: 3)

        XCTAssertEqual(.ropsten, server)
    }
}
