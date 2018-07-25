// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust

class GasViewModelTest: XCTestCase {

    let viewModel = GasViewModel.make()

    func testEtherFee() {
        let expectedResult = "\(viewModel.formatter.string(from: viewModel.fee)) \(viewModel.server.symbol)"
        let result = viewModel.etherFee
        XCTAssertEqual(expectedResult, result)
    }
}
