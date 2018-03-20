// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust
import TrustKeystore
import RealmSwift

class TransactionsStorageTests: XCTestCase {

    func testInit() {
        let storage = FakeTransactionsStorage()

        XCTAssertNotNil(storage)
        XCTAssertEqual(0, storage.transactions.count)
    }

    func testAddItem() {
        let storage = FakeTransactionsStorage()
        let item: Transaction = .make()

        storage.add([item])

        XCTAssertEqual(1, storage.transactions.count)
    }

    func testAddItems() {
        let storage = FakeTransactionsStorage()

        storage.add([
            .make(id: "0x1"),
            .make(id: "0x2")
        ])

        XCTAssertEqual(2, storage.transactions.count)
    }

    func testAddItemsDuplicate() {
        let storage = FakeTransactionsStorage()

        storage.add([
            .make(id: "0x1"),
            .make(id: "0x1"),
            .make(id: "0x2")
        ])

        XCTAssertEqual(2, storage.transactions.count)
    }

    func testDelete() {
        let storage = FakeTransactionsStorage()
        let one: Transaction = .make(id: "0x1")
        let two: Transaction = .make(id: "0x2")

        storage.add([
            one,
            two,
        ])

        XCTAssertEqual(2, storage.transactions.count)

        storage.delete([one])

        XCTAssertEqual(1, storage.transactions.count)

        XCTAssertEqual(two, storage.transactions.first)
    }

    func testDeleteAll() {
        let storage = FakeTransactionsStorage()

        storage.add([
            .make(id: "0x1"),
            .make(id: "0x2")
        ])

        XCTAssertEqual(2, storage.transactions.count)

        storage.deleteAll()

        XCTAssertEqual(0, storage.transactions.count)
    }
}
