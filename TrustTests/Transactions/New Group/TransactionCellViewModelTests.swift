// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class TransactionCellViewModelTests: XCTestCase {

    func testErrorState() {
        let viewModel = TransactionCellViewModel(transaction: .make(isError: true), chainState: .make())

        XCTAssertEqual(.error, viewModel.state)
    }

    func testPendingState() {
        let blockNumber = 1
        let chainState: ChainState = .make()
        chainState.latestBlock = blockNumber

        let viewModel = TransactionCellViewModel(transaction: .make(blockNumber: blockNumber), chainState: chainState)

        XCTAssertEqual(.pending, viewModel.state)
        XCTAssertEqual(0, viewModel.confirmations)
    }

    func testCompleteStateWhenLatestBlockBehind() {
        let blockNumber = 3
        let chainState: ChainState = .make()
        chainState.latestBlock = blockNumber - 1

        let viewModel = TransactionCellViewModel(transaction: .make(blockNumber: blockNumber), chainState: chainState)

        XCTAssertEqual(.completed, viewModel.state)
        XCTAssertNil(viewModel.confirmations)
    }

    func testCompleteState() {
        let blockNumber = 3
        let chainState: ChainState = .make()
        chainState.latestBlock = blockNumber

        let viewModel = TransactionCellViewModel(transaction: .make(blockNumber: 1), chainState: chainState)

        XCTAssertEqual(.completed, viewModel.state)
        XCTAssertEqual(2, viewModel.confirmations)
    }
}
