// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class RequestViewModelTests: XCTestCase {
    
    func testMyAddressText() {
        let account: Account = .make()
        let viewModel = RequestViewModel(account: account, config: .make())

        XCTAssertEqual(account.address.address, viewModel.myAddressText)
    }

    func testShareMyAddressText() {
        let account: Account = .make()
        let config: Config = .make()
        let viewModel = RequestViewModel(account: account, config: .make())

        XCTAssertEqual("My \(config.server.brandName) address is: \(account.address.address)", viewModel.shareMyAddressText)
    }
}
