// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust

class RPCServerTests: XCTestCase {
    
    func testMainNetwork() {
        let server = RPCServer(chainID: 1)

        XCTAssertEqual(.main, server)
    }
}
