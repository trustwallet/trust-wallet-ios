// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust
import TrustCore

class RequestViewModelTests: XCTestCase {
    
    func testMyAddressTextOfCoin() {
        let account: WalletInfo = .make()
        let viewModel = RequestViewModel(coinTypeViewModel: CoinTypeViewModel(type: .coin(account.currentAccount, .make())))

        XCTAssertEqual(account.currentAccount.address.description, viewModel.myAddressText)
    }

    func testMyAddressTextOfToken() {
        let account: WalletInfo = .make()
        let token = TokenObject(contract: "0x00000000000000000000000000000000000000AC", coin: .ethereum, type: .ERC20, value: "0")
        let viewModel = RequestViewModel(coinTypeViewModel: CoinTypeViewModel(type: .tokenOf(account.currentAccount, token)))

        XCTAssertEqual(account.currentAccount.address.description, viewModel.myAddressText)
    }

    func testShareMyAddressText() {
        let account = WalletInfo.make().currentAccount!
        let token: TokenObject = .make()
        let viewModel = CoinTypeViewModel(type: .coin(account, token))
        let requestViewModel = RequestViewModel(coinTypeViewModel: viewModel)

        XCTAssertEqual("My \(token.name) address is: \(account.address.description)", requestViewModel.shareMyAddressText)
    }
}
