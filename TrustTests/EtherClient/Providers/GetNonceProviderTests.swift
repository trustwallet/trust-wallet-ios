// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust
import BigInt
import TrustCore

class GetNonceProviderTests: XCTestCase {
    
    func testDefault() {
        let provider = GetNonceProvider(storage: FakeTransactionsStorage(), server: .make(), address: EthereumAddress.make())

        XCTAssertNil(provider.latestNonce)
        XCTAssertNil(provider.nextNonce)
    }

    func testExistOneTransaction() {
        let storage = FakeTransactionsStorage()
        storage.add([.make(nonce: 0)])
        let provider = GetNonceProvider(
            storage: storage,
            server: .make(),
            address: EthereumAddress.make()
        )

        XCTAssertEqual(BigInt(0), provider.latestNonce)
        XCTAssertEqual(BigInt(1), provider.nextNonce)
    }

    func testTransactionsSplitByCoins() {
        let storage = FakeTransactionsStorage()
        storage.add([
            .make(nonce: 0, coin: .poa),
        ])
        let provider = GetNonceProvider(
            storage: storage,
            server: .make(),
            address: EthereumAddress.make()
        )

        XCTAssertNil(provider.latestNonce)
        XCTAssertNil(provider.nextNonce)
    }

    func testExistMultipleTransactions() {
        let storage = FakeTransactionsStorage()
        storage.add([.make(nonce: 5),.make(nonce: 6)])
        let provider = GetNonceProvider(
            storage: storage,
            server: .make(),
            address: EthereumAddress.make()
        )

        XCTAssertEqual(BigInt(6), provider.latestNonce)
        XCTAssertEqual(BigInt(7), provider.nextNonce)
    }

    func testChangingNonceWhenNewTransactionAdded() {
        let storage = FakeTransactionsStorage()
        storage.add([.make(nonce: 5)])
        let provider = GetNonceProvider(
            storage: storage,
            server: .make(),
            address: EthereumAddress.make()
        )

        XCTAssertEqual(BigInt(5), provider.latestNonce)
        XCTAssertEqual(BigInt(6), provider.nextNonce)

        storage.add([.make(nonce: 6)])

        XCTAssertEqual(BigInt(6), provider.latestNonce)
        XCTAssertEqual(BigInt(7), provider.nextNonce)
    }
}
