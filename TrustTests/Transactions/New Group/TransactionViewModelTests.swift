// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class TransactionViewModelTests: XCTestCase {

    func testErrorState() {
        let viewModel = TransactionViewModel(transaction: .make(isError: true), config: .make(), chainState: .make())

        XCTAssertEqual(.error, viewModel.state)
    }

    func testPendingState() {
        let blockNumber = 1
        let chainState: ChainState = .make()
        chainState.latestBlock = blockNumber

        let viewModel = TransactionViewModel(transaction: .make(blockNumber: blockNumber), config: .make(), chainState: chainState)

        XCTAssertEqual(.pending, viewModel.state)
        XCTAssertEqual(0, viewModel.confirmations)
    }

    func testCompleteStateWhenLatestBlockBehind() {
        let blockNumber = 3
        let chainState: ChainState = .make()
        chainState.latestBlock = blockNumber - 1

        let viewModel = TransactionViewModel(transaction: .make(blockNumber: blockNumber), config: .make(), chainState: chainState)

        XCTAssertEqual(.completed, viewModel.state)
        XCTAssertNil(viewModel.confirmations)
    }

    func testCompleteState() {
        let blockNumber = 3
        let chainState: ChainState = .make()
        chainState.latestBlock = blockNumber

        let viewModel = TransactionViewModel(transaction: .make(blockNumber: 1), config: .make(), chainState: chainState)

        XCTAssertEqual(.completed, viewModel.state)
        XCTAssertEqual(2, viewModel.confirmations)
    }
}
