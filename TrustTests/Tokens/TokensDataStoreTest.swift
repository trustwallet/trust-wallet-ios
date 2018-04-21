// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class TokensDataStoreTest: XCTestCase {
    var tokensDataStore: TokensDataStore!
    var coinTickers: [CoinTicker]!

    override func setUp() {
        super.setUp()

        let config = Config.make()
        let tickersKey = config.tickersKey

        tokensDataStore = TokensDataStore(realm: .make(), config: config)

        coinTickers = [
            CoinTicker(id: "id1", symbol: "symbol1", price: "10", percent_change_24h: "percent_change_24h_1", contract: "contract1", image: "image1", tickersKey: tickersKey),
            CoinTicker(id: "id2", symbol: "symbol2", price: "20", percent_change_24h: "percent_change_24h_2", contract: "contract2", image: "image2", tickersKey: tickersKey),
            CoinTicker(id: "id3", symbol: "symbol3", price: "30", percent_change_24h: "percent_change_24h_3", contract: "contract3", image: "image3", tickersKey: tickersKey),
        ]
    }

    func testGetAndSetTickers() {
        XCTAssertEqual(0, tokensDataStore.tickers().count)

        tokensDataStore.saveTickers(tickers: coinTickers)
        
        let returnedCoinTickers = tokensDataStore.tickers()
        
        XCTAssertEqual(3, returnedCoinTickers.count)
        XCTAssertEqual("id1", returnedCoinTickers[0].id)
        XCTAssertEqual("id2", returnedCoinTickers[1].id)
        XCTAssertEqual("id3", returnedCoinTickers[2].id)
    }
    
    func testDeleteTickers() {
        XCTAssertEqual(0, tokensDataStore.realm.objects(CoinTicker.self).count)
        XCTAssertEqual(0, tokensDataStore.tickers().count)

        do {
            let coinTicker = CoinTicker(
                id: "",
                symbol: "",
                price: "",
                percent_change_24h: "",
                contract: "",
                image: "",
                tickersKey: "This is a tickers key that does not match anyone"
            )
            try tokensDataStore.realm.write {
                tokensDataStore.realm.add(coinTicker, update: true)
            }
        } catch let error {
            print(error.localizedDescription)
        }

        XCTAssertEqual(1, tokensDataStore.realm.objects(CoinTicker.self).count)
        XCTAssertEqual(0, tokensDataStore.tickers().count)

        let coinTickers = [
            CoinTicker(id: "id1", symbol: "", price: "", percent_change_24h: "", contract: "", image: "", tickersKey: tokensDataStore.config.tickersKey)
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
            contract: "contract1",
            decimals: 2,
            value: "10000"
        )

        XCTAssertEqual(1000.00, tokensDataStore.getBalance(for: tokenObject, with: coinTickers))

        XCTAssertEqual(0.00, tokensDataStore.getBalance(for: tokenObject, with: [CoinTicker(price: "", contract: "contract1")]))
        XCTAssertEqual(0.00, tokensDataStore.getBalance(for: tokenObject, with: [CoinTicker]()))

        tokenObject = TokenObject(
            contract: "contract2",
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
}
