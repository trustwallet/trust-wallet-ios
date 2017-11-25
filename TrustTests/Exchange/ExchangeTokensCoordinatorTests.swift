// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class ExchangeTokensCoordinatorTests: XCTestCase {
    
    func testInitial() {
        let account1: ExchangeToken = .make(symbol: "1")
        let account2: ExchangeToken = .make(symbol: "2")

        let coordinator = ExchangeTokensCoordinator(session: .make(), tokens: [
            account1,
            account2
        ])

        XCTAssertEqual(account1, coordinator.from)
        XCTAssertEqual(account2, coordinator.to)
    }

    func testRevertIfSameTokenSelected() {
        let account1: ExchangeToken = .make(symbol: "1")
        let account2: ExchangeToken = .make(symbol: "2")

        let coordinator = ExchangeTokensCoordinator(session: .make(), tokens: [
            account1,
            account2
        ])

        coordinator.changeToken(direction: .from, token: account2)

        XCTAssertEqual(account1, coordinator.to)
        XCTAssertEqual(account2, coordinator.from)
    }

    func testEthereumAlwaysInPair() {
        let exchangeConfig = ExchangeConfig(server: .kovan)
        
        let account1: ExchangeToken = .make(address: exchangeConfig.tokenAddress, symbol: "1")
        let account2: ExchangeToken = .make(symbol: "2")
        let account3: ExchangeToken = .make(symbol: "3")

        let coordinator = ExchangeTokensCoordinator(session: .make(), tokens: [
            account1,
            account2,
            account3
        ])

        XCTAssertEqual(account1, coordinator.from)
        XCTAssertEqual(account3, coordinator.to)

        coordinator.changeToken(direction: .from, token: account2)

        XCTAssertEqual(account2, coordinator.from)
        XCTAssertEqual(account1, coordinator.to)

        coordinator.changeToken(direction: .to, token: account3)

        XCTAssertEqual(account1, coordinator.from)
        XCTAssertEqual(account3, coordinator.to)
    }
}

