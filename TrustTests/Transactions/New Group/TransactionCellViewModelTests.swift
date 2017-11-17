// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class TransactionCellViewModelTests: XCTestCase {

    func testErrorState() {
        let viewModel = TransactionCellViewModel(transaction: .make(isError: true), chainState: .make())

        XCTAssertEqual(.error, viewModel.state)
    }
}
