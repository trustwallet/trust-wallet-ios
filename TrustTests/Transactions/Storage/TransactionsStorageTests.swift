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

    func testTwoTransactionsDifferentChainID() {
        let owner: Account = .make(address: Address(address: "0x3"))
        let storage = FakeTransactionsStorage(owner, chainID: 1)

        storage.add([.make(id: "0x1", owner: owner.address.address, chainID: 1)])
        storage.add([.make(id: "0x2", owner: owner.address.address, chainID: 2)])

        XCTAssertEqual(1, storage.count)
        XCTAssertEqual(1, storage.objects.first?.chainID)
    }

    func testTwoTransactionsDifferentOwner() {
        let owner: Account = .make(address: Address(address: "0x1"))
        let storage = FakeTransactionsStorage(owner, chainID: 1)

        storage.add([.make(id: "0x1", owner: owner.address.address, chainID: 1)])
        storage.add([.make(id: "0x2", owner: "0x2", chainID: 1)])

        XCTAssertEqual(1, storage.count)
        XCTAssertEqual(1, storage.objects.first?.chainID)
        XCTAssertEqual(owner.address.address, storage.objects.first?.owner)
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
        let one: Transaction = .make(id: "0x1")
        let two: Transaction = .make(id: "0x2")

        storage.add([
            one,
            two,
        ])

        XCTAssertEqual(2, storage.count)

        storage.delete([one])

        XCTAssertEqual(1, storage.count)

        XCTAssertEqual(two, storage.objects.first)
    }

    func testDeleteForOwner() {
        let storage = FakeTransactionsStorage()
        let owner: Account = .make()

        storage.add([
            .make(id: "0x1", owner: owner.address.address),
            .make(id: "0x2", owner: owner.address.address)
        ])

        XCTAssertEqual(2, storage.count)

        storage.delete(for: owner)

        XCTAssertEqual(0, storage.count)
    }

    func testDeleteAll() {
        let storage = FakeTransactionsStorage()

        storage.add([
            .make(id: "0x1"),
            .make(id: "0x2")
        ])

        XCTAssertEqual(2, storage.count)

        storage.deleteAll()

        XCTAssertEqual(0, storage.count)
    }
}
