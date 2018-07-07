// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust
import BigInt

class GetNonceProviderTests: XCTestCase {
    
    func testDefault() {
        let provider = GetNonceProvider(storage: FakeTransactionsStorage())

        XCTAssertNil(provider.latestNonce)
        XCTAssertNil(provider.nextNonce)
    }

    func testExistOneTransaction() {
        let storage = FakeTransactionsStorage()
        storage.add([.make(nonce: 0)])
        let provider = GetNonceProvider(
            storage: storage
        )

        XCTAssertEqual(BigInt(0), provider.latestNonce)
        XCTAssertEqual(BigInt(1), provider.nextNonce)
    }

    func testExistMultipleTransactions() {
        let storage = FakeTransactionsStorage()
        storage.add([.make(nonce: 5),.make(nonce: 6)])
        let provider = GetNonceProvider(
            storage: storage
        )

        XCTAssertEqual(BigInt(6), provider.latestNonce)
        XCTAssertEqual(BigInt(7), provider.nextNonce)
    }

    func testChangingNonceWhenNewTransactionAdded() {
        let storage = FakeTransactionsStorage()
        storage.add([.make(nonce: 5)])
        let provider = GetNonceProvider(
            storage: storage
        )

        XCTAssertEqual(BigInt(5), provider.latestNonce)
        XCTAssertEqual(BigInt(6), provider.nextNonce)

        storage.add([.make(nonce: 6)])

        XCTAssertEqual(BigInt(6), provider.latestNonce)
        XCTAssertEqual(BigInt(7), provider.nextNonce)
    }
}
