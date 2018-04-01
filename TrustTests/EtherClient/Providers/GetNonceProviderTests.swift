// Copyright SIX DAY LLC. All rights reserved.

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
        storage.add([.make(nonce: "0")])
        let provider = GetNonceProvider(
            storage: storage
        )

        XCTAssertEqual(0, provider.latestNonce)
        XCTAssertEqual(1, provider.nextNonce)
    }

    func testExistMultipleTransactions() {
        let storage = FakeTransactionsStorage()
        storage.add([.make(nonce: "5"),.make(nonce: "6")])
        let provider = GetNonceProvider(
            storage: storage
        )

        XCTAssertEqual(6, provider.latestNonce)
        XCTAssertEqual(7, provider.nextNonce)
    }

    func testChangingNonceWhenNewTransactionAdded() {
        let storage = FakeTransactionsStorage()
        storage.add([.make(nonce: "5")])
        let provider = GetNonceProvider(
            storage: storage
        )

        XCTAssertEqual(5, provider.latestNonce)
        XCTAssertEqual(6, provider.nextNonce)

        storage.add([.make(nonce: "6")])

        XCTAssertEqual(6, provider.latestNonce)
        XCTAssertEqual(7, provider.nextNonce)
    }

    func testProvidedNonce() {
        let storage = FakeTransactionsStorage()
        storage.add([.make(nonce: "6")])
        let provider = GetNonceProvider(
            storage: storage
        )
        let nonce = provider.getNonce(for: .make(nonce: BigInt(123)))

        XCTAssertEqual(123, nonce)
    }

    func testNotProvidedNonce() {
        let storage = FakeTransactionsStorage()
        storage.add([.make(nonce: "6")])
        let provider = GetNonceProvider(
            storage: storage
        )
        let nonce = provider.getNonce(for: .make(nonce: .none))

        XCTAssertEqual(7, nonce)
    }
}
