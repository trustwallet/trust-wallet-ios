// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust

class IsHexStringTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testValid() {
        XCTAssertTrue("0x0e026d45820d91356fc73d7ff2bdef353ebfe7e9".isHexEncoded)
        XCTAssertTrue("0x1e026d45820d91356fc73d7ff2bdef353ebfe7e9".isHexEncoded)
        XCTAssertTrue("0x6e026d45820d91356fc73d7ff2bdef353ebfe7e9".isHexEncoded)
        XCTAssertTrue("0xecfaa1a0c4372a2ac5cca1e164510ec8df04f681fc960797f1419802ec00b225".isHexEncoded)
        XCTAssertTrue("0x6e0e6d45820d91356fc73d7ff2bdef353ebfe7e9".isHexEncoded)
        XCTAssertTrue("0x620e6d45820d91356fc73d7ff2bdef353ebfe7e9".isHexEncoded)
        XCTAssertTrue("0x1e0e6d45820d91356fc73d7ff2bdef353ebfe7e9".isHexEncoded)
        XCTAssertTrue("0x2e0e6d45820d91356fc73d7ff2bdef353ebfe7e9".isHexEncoded)
        XCTAssertTrue("0x220c96d48733a847570c2f0b40daa8793b3ae875b26a4ead1f0f9cead05c3863".isHexEncoded)
        XCTAssertTrue("0x2bb303f0ae65c64ef80a3bb3ee8ceef5d50065bd".isHexEncoded)
        XCTAssertTrue("0x6e026d45820d91256fc73d7ff2bdef353ebfe7e9".isHexEncoded)
    }

    func testInvalid() {
        XCTAssertFalse(" 0x0e026d45820d91356fc73d7ff2bdef353ebfe7e9".isHexEncoded)
        XCTAssertFalse("fdsjfsd".isHexEncoded)
        XCTAssertFalse(" 0xfdsjfsd".isHexEncoded)
        XCTAssertFalse("0xfds*jfsd".isHexEncoded)
        XCTAssertFalse("0xfds$jfsd".isHexEncoded)
        XCTAssertFalse("0xf@dsjfsd".isHexEncoded)
        XCTAssertFalse("0xfdsjf!sd".isHexEncoded)
        XCTAssertFalse("fds@@jfsd".isHexEncoded)
    }
}
