// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust

class PasswordGeneratorTests: XCTestCase {
    
    func testGenerateRandom() {
        let password = PasswordGenerator.generateRandom()

        XCTAssertEqual(64, password.count)
    }

    func testGenerateRandomBytes() {
        let password = PasswordGenerator.generateRandomString(bytesCount: 8)

        XCTAssertEqual(16, password.count)
    }
}
