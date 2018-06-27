// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class TokensDataStoreTest: XCTestCase {
    var tokensDataStore = TokensDataStore(realm: .make(), config: .make())

    func testGetAndSetTickers() {
        XCTAssertEqual(0, tokensDataStore.tickers().count)

        tokensDataStore.saveTickers(tickers: FakeCoinTickerFactory.make3UniqueCionTickers())
        
        let returnedCoinTickers = tokensDataStore.tickers()
        
        XCTAssertEqual(3, returnedCoinTickers.count)
    }
    
    func testDeleteTickers() {
        XCTAssertEqual(0, tokensDataStore.realm.objects(CoinTicker.self).count)
        XCTAssertEqual(0, tokensDataStore.tickers().count)

        do {
            try tokensDataStore.realm.write {
                tokensDataStore.realm.add(CoinTicker.make(currencyKey: "This is a ticker currency key that does not match anyone"), update: true)
            }
        } catch let error {
            print(error.localizedDescription)
        }

        XCTAssertEqual(1, tokensDataStore.realm.objects(CoinTicker.self).count)
        XCTAssertEqual(0, tokensDataStore.tickers().count)

        let coinTickers = [
            CoinTicker.make(currencyKey: CoinTickerKeyMaker.makeCurrencyKey(for: Config.make()))
        ]

        tokensDataStore.saveTickers(tickers: coinTickers)

        XCTAssertEqual(2, tokensDataStore.realm.objects(CoinTicker.self).count)
        XCTAssertEqual(1, tokensDataStore.tickers().count)

        tokensDataStore.deleteAllExistingTickers()

        XCTAssertEqual(1, tokensDataStore.realm.objects(CoinTicker.self).count)
        XCTAssertEqual(0, tokensDataStore.tickers().count)
    }

    func testGetBalance() {
        var tokenObject = TokenObject(
            contract: "0x0000000000000000000000000000000000000001",
            decimals: 2,
            value: "10000"
        )

        let coinTickers = FakeCoinTickerFactory.make3UniqueCionTickers()

        XCTAssertEqual(1000.00, tokensDataStore.getBalance(for: tokenObject, with: coinTickers))

        XCTAssertEqual(0.00, tokensDataStore.getBalance(for: tokenObject, with: [CoinTicker(price: "", contract: .make())]))
        XCTAssertEqual(0.00, tokensDataStore.getBalance(for: tokenObject, with: [CoinTicker]()))

        tokenObject = TokenObject(
            contract: "0x0000000000000000000000000000000000000002",
            decimals: 3,
            value: "20000"
        )

        XCTAssertEqual(400.00, tokensDataStore.getBalance(for: tokenObject, with: coinTickers))

        tokenObject = TokenObject(
            contract: "contract that doesn't match any",
            decimals: 4,
            value: "30000"
        )

        XCTAssertEqual(0.00, tokensDataStore.getBalance(for: tokenObject, with: coinTickers))
    }

    // This test checks that even the key generation algorithm changes, coinTicker(for:) still can pick up the correct CoinTicker object without needing to delete the old CoinTicker records since they have old key.
    func testGetCoinTickerForAParticularToken() {
        tokensDataStore.saveTickers(tickers: FakeCoinTickerFactory.make2DuplicateCionTickersWithDifferentKey())

        let token = TokenObject(contract: "0x0000000000000000000000000000000000000001", name: "", symbol: "symbol1", decimals: 18, value: "", isCustom: false, isDisabled: false)

        let coinTicker = tokensDataStore.coinTicker(for: token)

        XCTAssertEqual("symbol1_0x0000000000000000000000000000000000000001_tickers-USD-1", coinTicker?.key)
    }
}
