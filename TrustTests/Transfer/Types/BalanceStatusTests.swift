// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust

class BalanceStatusTests: XCTestCase {

    func testSufficientEth() {
        let status: BalanceStatus = .ether(etherSufficient: true, gasSufficient: true)
        XCTAssertTrue(status.sufficient)
        XCTAssertEqual(.correct, status.insufficientTextKey)
    }

    func testInsufficientGasForEth() {
        let status: BalanceStatus = .ether(etherSufficient: true, gasSufficient: false)
        XCTAssertFalse(status.sufficient)
        XCTAssertEqual(.insufficientGas, status.insufficientTextKey)
    }

    func testInsufficientEth() {
        let status: BalanceStatus = .ether(etherSufficient: false, gasSufficient: true)
        XCTAssertFalse(status.sufficient)
        XCTAssertEqual(.insufficientEther, status.insufficientTextKey)

        let status2: BalanceStatus = .ether(etherSufficient: false, gasSufficient: false)
        XCTAssertFalse(status2.sufficient)
        XCTAssertEqual(.insufficientEther, status2.insufficientTextKey)
    }

    func testSufficientTokens() {
        let status: BalanceStatus = .token(tokenSufficient: true, gasSufficient: true)
        XCTAssertTrue(status.sufficient)
        XCTAssertEqual(.correct, status.insufficientTextKey)
    }

    func testInsufficientGasForTokens() {
        let status: BalanceStatus = .token(tokenSufficient: true, gasSufficient: false)
        XCTAssertFalse(status.sufficient)
        XCTAssertEqual(.insufficientGas, status.insufficientTextKey)
    }

    func testInsufficientTokens() {
        let status: BalanceStatus = .token(tokenSufficient: false, gasSufficient: true)
        XCTAssertFalse(status.sufficient)
        XCTAssertEqual(.insufficientToken, status.insufficientTextKey)

        let status2: BalanceStatus = .token(tokenSufficient: false, gasSufficient: false)
        XCTAssertFalse(status2.sufficient)
        XCTAssertEqual(.insufficientToken, status2.insufficientTextKey)
    }
}
