// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust
import RealmSwift

class TransactionsStorageTests: XCTestCase {

    func testInit() {
        let storage = FakeTransactionsStorage()

        XCTAssertNotNil(storage)
        XCTAssertEqual(0, storage.count)
    }

    func testAddItem() {
        let storage = FakeTransactionsStorage()
        let item: Transaction = .make()

        storage.add([item])

        XCTAssertEqual(1, storage.count)
    }

    func testAddItems() {
        let storage = FakeTransactionsStorage()

        storage.add([
            .make(id: "0x1"),
            .make(id: "0x2")
        ])

        XCTAssertEqual(2, storage.count)
    }

    func testAddItemsDuplicate() {
        let storage = FakeTransactionsStorage()

        storage.add([
            .make(id: "0x1"),
            .make(id: "0x1"),
            .make(id: "0x2")
        ])

        XCTAssertEqual(2, storage.count)
    }

    func testDelete() {
        let storage = FakeTransactionsStorage()

        let items = storage.add([
            .make(id: "0x1"),
            .make(id: "0x2")
        ])

        XCTAssertEqual(2, storage.count)

        storage.delete(items)

        XCTAssertEqual(0, storage.count)
    }
}
