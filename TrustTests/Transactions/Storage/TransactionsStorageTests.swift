// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust
import TrustKeystore
import RealmSwift

class TransactionsStorageTests: XCTestCase {

    func testInit() {
        let storage = FakeTransactionsStorage()

        XCTAssertNotNil(storage)
        XCTAssertEqual(0, storage.objects.count)
    }

    func testAddItem() {
        let storage = FakeTransactionsStorage()
        let item: Transaction = .make()

        storage.add([item])

        XCTAssertEqual(1, storage.objects.count)
    }

    func testAddItems() {
        let storage = FakeTransactionsStorage()

        storage.add([
            .make(id: "0x1"),
            .make(id: "0x2")
        ])

        XCTAssertEqual(2, storage.objects.count)
    }

    func testAddItemsDuplicate() {
        let storage = FakeTransactionsStorage()

        storage.add([
            .make(id: "0x1"),
            .make(id: "0x1"),
            .make(id: "0x2")
        ])

        XCTAssertEqual(2, storage.objects.count)
    }

    func testDelete() {
        let storage = FakeTransactionsStorage()
        let one: Transaction = .make(id: "0x1")
        let two: Transaction = .make(id: "0x2")

        storage.add([
            one,
            two,
        ])

        XCTAssertEqual(2, storage.objects.count)

        storage.delete([one])

        XCTAssertEqual(1, storage.objects.count)

        XCTAssertEqual(two, storage.objects.first)
    }

    func testDeleteAll() {
        let storage = FakeTransactionsStorage()

        storage.add([
            .make(id: "0x1"),
            .make(id: "0x2")
        ])

        XCTAssertEqual(2, storage.objects.count)

        storage.deleteAll()

        XCTAssertEqual(0, storage.objects.count)
    }
}
