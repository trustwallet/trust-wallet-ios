// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class SendViewModelTest: XCTestCase {
    var sendViewModel = SendViewModel(transferType: .ether(destination: .none), config: .make())
    override func setUp() {
        sendViewModel.amount = "198212312.123123"
        super.setUp()
    }
    func testPairRateRepresantetio() {
        sendViewModel.pairRate = 128.9
        let fiatRepresentation = sendViewModel.pairRateRepresantetion()
        XCTAssertEqual("~ 128.90 USD", fiatRepresentation)
        sendViewModel.pairRate = 298981.983212
        sendViewModel.currentPair = sendViewModel.currentPair.swapPair()
        let cryptoRepresentation = sendViewModel.pairRateRepresantetion()
        XCTAssertEqual("~ 298981.983212 ETH", cryptoRepresentation)
    }
    func testUpdatePairRate() {
        XCTAssertEqual(0.0, sendViewModel.pairRate)
        sendViewModel.updatePaitRate(with: 1.8, and: 300.2)
        XCTAssertEqual(540.36, sendViewModel.pairRate)
        sendViewModel.currentPair = sendViewModel.currentPair.swapPair()
        sendViewModel.updatePaitRate(with: 24.3, and: 967)
        XCTAssertEqual(sendViewModel.pairRate.doubleValue, 39.794238683127, accuracy: 0.000000000001)
    }
    func testRate() {
        sendViewModel.pairRate = 298.124453
        _ = sendViewModel.pairRateRepresantetion()
        XCTAssertEqual("298.12", sendViewModel.rate)
        sendViewModel.pairRate = 12.53453
        sendViewModel.currentPair = sendViewModel.currentPair.swapPair()
        _ = sendViewModel.pairRateRepresantetion()
        XCTAssertEqual("12.53453", sendViewModel.rate)
    }
    func testAmount() {
        XCTAssertEqual("198212312.123123", sendViewModel.amount)
    }
    func testDecimals() {
        XCTAssertEqual(18, sendViewModel.decimals)
    }
}
