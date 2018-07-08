// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust
import BigInt

class TokensViewModelTest: XCTestCase {
    let model = TokensViewModel(
        address: .make(),
        store: FakeTokensDataStore(),
        tokensNetwork: FakeTokensNetwork(
            provider: TrustProviderFactory.makeProvider(),
            APIProvider: TrustProviderFactory.makeAPIProvider(),
            balanceService: FakeGetBalanceCoordinator(),
            account: .make(),
            config: .make()
        ),
        transactionStore: FakeTransactionsStorage()
    )
    let firstItem = IndexPath(row: 0, section: 0)

    func testNumberOfTokens() {
        XCTAssertEqual(1, model.numberOfItems(for: 0))
    }

    func testItem() {
        let item = model.item(for: firstItem)
        XCTAssertNotNil(item)
    }

    func testCellViewModel() {
        let item = model.cellViewModel(for: firstItem)
        let token = model.tokens[firstItem.row]
        XCTAssertEqual(item.token, token)
    }

    func testCanEdit() {
         XCTAssertEqual(false, model.canEdit(for: firstItem))
    }

//    func testUpdateTicker() {
//        model.updateTickers()
//        let ethTicker = model.store.tickers().first
//        XCTAssertNotNil(ethTicker)
//        XCTAssertEqual("947.102", ethTicker?.price)
//    }

    func testBalance() {
        model.updateEthBalance()
        let token = model.tokens[firstItem.row]
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
            XCTAssertNotNil(token)
            XCTAssertEqual(BigInt(100), token.valueBigInt)
        })
    }
}
