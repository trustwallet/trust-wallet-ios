// Copyright DApps Platform Inc. All rights reserved.

import XCTest
import BigInt
@testable import Trust

class SendMaxAmountTest: XCTestCase {
    let formatter = EtherNumberFormatter()
    let decimalSeparator = Locale.current.decimalSeparator ?? "."
    func testMaxEther() {
        var viewModel = SendViewModel(transferType: .ether(destination: .none), config: .make(), chainState: .make(), storage: FakeTokensDataStore(), balance: Balance(value:BigInt("11274902618710000000000")))
        let max = viewModel.sendMaxAmount()
        XCTAssertEqual("11274\(decimalSeparator)90261871", max)
    }
    func testMaxToken() {
        let token = TokenObject(contract: "0xe41d2489571d322189246dafa5ebde1f4699f498", name: "0x project", symbol: "ZRX", decimals: 18, value: "39330812000000000000000", isCustom: true, isDisabled: false)
        var viewModel = SendViewModel(transferType: .token(token), config: .make(), chainState: .make(), storage: FakeTokensDataStore(), balance: Balance(value:BigInt(0)))
        let max = viewModel.sendMaxAmount()
        XCTAssertEqual("39330\(decimalSeparator)812", max)
    }
}
