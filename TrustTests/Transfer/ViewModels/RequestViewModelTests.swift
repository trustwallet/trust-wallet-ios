// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust
import TrustCore

class RequestViewModelTests: XCTestCase {
    
    func testMyAddressText() {
        let account: Trust.Wallet = .make()
        let viewModel = RequestViewModel(account: account, config: .make(), token: .make())

        XCTAssertEqual(account.address.description, viewModel.myAddressText)
    }

    func testShareMyAddressText() {
        let account: Trust.Wallet = .make()
        let config: Config = .make()
        let viewModel = RequestViewModel(account: account, config: .make(), token: .make())

        XCTAssertEqual("My \(config.server.name) address is: \(account.address.description)", viewModel.shareMyAddressText)
    }
}
