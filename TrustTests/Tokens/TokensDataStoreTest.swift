// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class TokensDataStoreTest: XCTestCase {
    let tokensDataStore = TokensDataStore(realm: .make(), config: .make())
    
    func testGetAndSetTickers() {
        XCTAssertEqual(0, tokensDataStore.tickers().count)
        
        let coinTickers = [
            CoinTicker(id: "id1", symbol: "symbol1", price: "price1", percent_change_24h: "percent_change_24h_1", contract: "contract1", image: "image1"),
            CoinTicker(id: "id2", symbol: "symbol2", price: "price2", percent_change_24h: "percent_change_24h_2", contract: "contract2", image: "image2"),
            CoinTicker(id: "id3", symbol: "symbol3", price: "price3", percent_change_24h: "percent_change_24h_3", contract: "contract3", image: "image3"),
        ]
        
        tokensDataStore.saveTickers(tickers: coinTickers)
        
        let returnedCoinTickers = tokensDataStore.tickers()
        
        XCTAssertEqual(3, returnedCoinTickers.count)
        XCTAssertEqual("id1", returnedCoinTickers[0].id)
        XCTAssertEqual("id2", returnedCoinTickers[1].id)
        XCTAssertEqual("id3", returnedCoinTickers[2].id)
    }
    
    func testDeleteTickers() {
        tokensDataStore.deleteTickers()
    }
}
