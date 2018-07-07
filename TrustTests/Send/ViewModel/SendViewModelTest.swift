// Copyright DApps Platform Inc. All rights reserved.

import XCTest
import BigInt
@testable import Trust

class SendViewModelTest: XCTestCase {
    var sendViewModel = SendViewModel(transferType: .ether(destination: .none), config: .make(), chainState: .make(), storage: FakeTokensDataStore(), balance: Balance(value: BigInt("11274902618710000000000")))
    var decimalFormatter = DecimalFormatter()
    override func setUp() {
        sendViewModel.amount = "198212312.123123"
        super.setUp()
    }
    func testPairRateRepresantetio() {
        let expectedFiatResult = sendViewModel.stringFormatter.currency(with: 128.9, and: sendViewModel.config.currency.rawValue)
        sendViewModel.pairRate = 128.9
        let fiatRepresentation = sendViewModel.pairRateRepresantetion()
        XCTAssertEqual("~ \(expectedFiatResult) USD", fiatRepresentation)
        let expectedCryptoResult = sendViewModel.stringFormatter.token(with: 298981.983212, and: sendViewModel.decimals)
        sendViewModel.pairRate = 298981.983212
        sendViewModel.currentPair = sendViewModel.currentPair.swapPair()
        let cryptoRepresentation = sendViewModel.pairRateRepresantetion()
        XCTAssertEqual("~ \(expectedCryptoResult) ETH", cryptoRepresentation)
    }
    func testUpdatePairRate() {
        XCTAssertEqual(0.0, sendViewModel.pairRate)
        sendViewModel.updatePairRate(with: 1.8, and: 300.2)
        XCTAssertEqual(540.36, sendViewModel.pairRate)
        sendViewModel.currentPair = sendViewModel.currentPair.swapPair()
        sendViewModel.updatePairRate(with: 24.3, and: 967)
        XCTAssertEqual(sendViewModel.pairRate.doubleValue, 39.794238683127, accuracy: 0.000000000001)
    }
    func testAmountUpdate() {
        XCTAssertEqual("198212312.123123", sendViewModel.amount)
        sendViewModel.updateAmount(with: "1.245")
        XCTAssertEqual("1.245", sendViewModel.amount)
    }
    func testRate() {
        let expectedFiatResult = sendViewModel.stringFormatter.currency(with: 298.124453, and: sendViewModel.config.currency.rawValue)
        sendViewModel.pairRate = 298.124453
        _ = sendViewModel.pairRateRepresantetion()
        XCTAssertEqual(expectedFiatResult, sendViewModel.rate)
        let expectedCryptoResult = sendViewModel.stringFormatter.token(with: 12.53453, and: sendViewModel.decimals)
        sendViewModel.pairRate = 12.53453
        sendViewModel.currentPair = sendViewModel.currentPair.swapPair()
        _ = sendViewModel.pairRateRepresantetion()
        XCTAssertEqual(expectedCryptoResult, sendViewModel.rate)
    }
    func testAmount() {
        XCTAssertEqual("198212312.123123", sendViewModel.amount)
    }
    func testDecimals() {
        XCTAssertEqual(18, sendViewModel.decimals)
    }
    func testStringToDecimal() {
        let curentLocaleSeparator = Locale.current.decimalSeparator ?? "."
        let amount = sendViewModel.decimalAmount(with: "256\(curentLocaleSeparator)32")
        XCTAssertEqual(256.32, amount)
        let failAmount = sendViewModel.decimalAmount(with: "xxxxx")
        XCTAssertEqual(0, failAmount)
        let bigAmount = sendViewModel.decimalAmount(with: "100000000\(curentLocaleSeparator)000000000000001")
        XCTAssertEqual(100000000.000000000000001, bigAmount)
    }
    func testMaxButtonVisability() {
        XCTAssertEqual(false, sendViewModel.isMaxButtonHidden())
        sendViewModel.currentPair = sendViewModel.currentPair.swapPair()
        XCTAssertEqual(true, sendViewModel.isMaxButtonHidden())
    }
}
