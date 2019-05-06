// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import IPOS

class TokenObjectViewModelTest: XCTestCase {

    func testTitle() {
        let viewModel = TokenObjectViewModel(token: .make(name: "Viktor", symbol: "VIK"))

        XCTAssertEqual("Viktor (VIK)", viewModel.title)
    }
}
