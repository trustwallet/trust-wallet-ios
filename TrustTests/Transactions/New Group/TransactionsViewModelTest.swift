// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class TransactionsViewModelTest: XCTestCase {
    let transactions = [Transaction(id: "0", date: Date().yesterday, state: .completed),Transaction(id: "1", date: Date(), state: .completed),Transaction(id: "2", date: Date().tomorrow, state: .completed)]
    var expectedTransactionsSection:[TransactionsSectionModel]!
    var viewModel:TransactionsViewModel!
    override func setUp() {
        self.viewModel = TransactionsViewModel(transactions: transactions, config: .make())
        self.expectedTransactionsSection = [TransactionsSectionModel(header: TransactionsViewModel.formatter.string(from:Date().yesterday ), items: [transactions[0]]),
                                            TransactionsSectionModel(header: TransactionsViewModel.formatter.string(from: Date() ), items: [transactions[1]]),
            TransactionsSectionModel(header: TransactionsViewModel.formatter.string(from: Date().tomorrow ), items: [transactions[2]])]
    }
    func testItemsSection() {
        XCTAssertEqual(viewModel.items.count, expectedTransactionsSection.count)
        for (pos,item) in viewModel.items.enumerated() {
             XCTAssertEqual(item.header, expectedTransactionsSection[pos].header)
             XCTAssertEqual(item.items.count, expectedTransactionsSection[pos].items.count)
             XCTAssertEqual(item.items.first?.id, expectedTransactionsSection[pos].items.first?.id)
        }
    }
    func testNumberOfSections() {
        XCTAssertEqual(viewModel.numberOfSections, 3)
    }
    func testNumberOfItemsInSections() {
        for (pos,_) in viewModel.items.enumerated() {
            XCTAssertEqual(viewModel.numberOfItems(for: pos), 1)
        }
    }
    func testTitleForHeader() {
        XCTAssertEqual(viewModel.titleForHeader(in: 0), "Yesterday")
        XCTAssertEqual(viewModel.titleForHeader(in: 1), "Today")
        XCTAssertEqual(viewModel.titleForHeader(in: 2), TransactionsViewModel.formatter.string(from: Date().tomorrow ))
    }
}
