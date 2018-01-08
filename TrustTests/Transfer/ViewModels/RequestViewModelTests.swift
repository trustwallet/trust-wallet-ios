// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust
import TrustKeystore

class RequestViewModelTests: XCTestCase {
    
    func testMyAddressText() {
        let account: Wallet = .make()
        let viewModel = RequestViewModel(account: account, config: .make())

        XCTAssertEqual(account.address.address, viewModel.myAddressText)
    }

    func testShareMyAddressText() {
        let account: Wallet = .make()
        let config: Config = .make()
        let viewModel = RequestViewModel(account: account, config: .make())

        XCTAssertEqual("My \(config.server.name) address is: \(account.address.address)", viewModel.shareMyAddressText)
    }
}
