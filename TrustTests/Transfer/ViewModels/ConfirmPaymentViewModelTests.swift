// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import IPOS

class ConfirmPaymentViewModelTests: XCTestCase {
    
    func testActionButtonTitleOnSign() {
        let viewModel = ConfirmPaymentViewModel(type: .sign)

        XCTAssertEqual("Approve", viewModel.actionButtonText)
    }

    func testActionButtonTitleOnSignAndSend() {
        let viewModel = ConfirmPaymentViewModel(type: .signThenSend)

        XCTAssertEqual("Send", viewModel.actionButtonText)
    }
}
