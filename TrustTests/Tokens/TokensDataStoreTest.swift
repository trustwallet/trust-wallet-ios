// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust

class TokensDataStoreTest: XCTestCase {
    var tokensDataStore = FakeTokensDataStore()

    func testGetAndSetTickers() {
        XCTAssertEqual(0, tokensDataStore.tickers.count)

        tokensDataStore.saveTickers(tickers: FakeCoinTickerFactory.make3UniqueCionTickers())
        
        let returnedCoinTickers = tokensDataStore.tickers
        
        XCTAssertEqual(3, returnedCoinTickers.count)
    }
    
    func testDeleteTickers() {
        XCTAssertEqual(0, tokensDataStore.realm.objects(CoinTicker.self).count)
        XCTAssertEqual(0, tokensDataStore.tickers.count)

        do {
            try tokensDataStore.realm.write {
                tokensDataStore.realm.add(CoinTicker.make(currencyKey: "This is a ticker currency key that does not match anyone"), update: true)
            }
        } catch let error {
            print(error.localizedDescription)
        }

        XCTAssertEqual(1, tokensDataStore.realm.objects(CoinTicker.self).count)
        XCTAssertEqual(0, tokensDataStore.tickers.count)

        let coinTickers = [
            CoinTicker.make(currencyKey: CoinTickerKeyMaker.makeCurrencyKey()),
        ]

        tokensDataStore.saveTickers(tickers: coinTickers)

        XCTAssertEqual(2, tokensDataStore.realm.objects(CoinTicker.self).count)
        XCTAssertEqual(1, tokensDataStore.tickers.count)

        tokensDataStore.deleteAllExistingTickers()

        XCTAssertEqual(1, tokensDataStore.realm.objects(CoinTicker.self).count)
        XCTAssertEqual(0, tokensDataStore.tickers.count)
    }

// Needs to insert CoinTicker and then fetch balance
//    func testGetBalance() {
//        let token = TokenObject(
//            contract: "0x0000000000000000000000000000000000000001",
//            coin: .ethereum,
//            type: .coin,
//            decimals: 2,
//            value: "10000"
//        )
//
//        tokensDataStore.add(tokens: [token])
//
//        XCTAssertEqual(1000.00, tokensDataStore.getBalance(for: token))
//    }

    func testGetBalanceForMissingToken() {
        let tokenObject = TokenObject(
            contract: "0x0000000000000000000000000000000000000005",
            coin: .ethereum,
            type: .coin,
            decimals: 2,
            value: "0"
        )

        XCTAssertEqual(0.00, tokensDataStore.getBalance(for: tokenObject.address, with: tokenObject.valueBigInt, and: tokenObject.decimals))
    }

    // This test checks that even the key generation algorithm changes, coinTicker(for:) still can pick up the correct CoinTicker object without needing to delete the old CoinTicker records since they have old key.
    func testGetCoinTickerForAParticularToken() {
        tokensDataStore.saveTickers(tickers: FakeCoinTickerFactory.make2DuplicateCionTickersWithDifferentKey())

        let token = TokenObject(
            contract: "0x0000000000000000000000000000000000000001",
            name: "",
            coin: .ethereum,
            type: .coin,
            symbol: "symbol1", decimals: 18, value: "", isCustom: false, isDisabled: false)

        let coinTicker = tokensDataStore.coinTicker(by: token.address)

        XCTAssertEqual("0x0000000000000000000000000000000000000001_tickers-USD", coinTicker?.key)
    }
}
