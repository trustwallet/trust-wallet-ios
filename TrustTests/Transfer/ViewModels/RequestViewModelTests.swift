// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust
import TrustKeystore

class RequestViewModelTests: XCTestCase {
    
    func testMyAddressText() {
        let account: Account = .make()
        let viewModel = RequestViewModel(account: account, config: .make())

        XCTAssertEqual(account.address.description, viewModel.myAddressText)
    }

    func testShareMyAddressText() {
        let account: Account = .make()
        let config: Config = .make()
        let viewModel = RequestViewModel(account: account, config: .make())

        XCTAssertEqual("My \(config.server.name) address is: \(account.address.description)", viewModel.shareMyAddressText)
    }
}
