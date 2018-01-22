// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class TransactionsStorage {

    let realm: Realm

    init(
        realm: Realm
    ) {
        self.realm = realm
    }

    var count: Int {
        return objects.count
    }

    var objects: [Transaction] {
        return realm.objects(Transaction.self)
            .sorted(byKeyPath: "date", ascending: false)
            .filter { !$0.id.isEmpty }
    }

    var completedObjects: [Transaction] {
        return objects.filter { $0.state == .completed }
    }

    var pendingObjects: [Transaction] {
        return objects.filter { $0.state == TransactionState.pending }
    }

    func get(forPrimaryKey: String) -> Transaction? {
        return realm.object(ofType: Transaction.self, forPrimaryKey: forPrimaryKey)
    }

    @discardableResult
    func add(_ items: [Transaction]) -> [Transaction] {
        realm.beginWrite()
        realm.add(items, update: true)
        try! realm.commitWrite()
        return items
    }

    func delete(_ items: [Transaction]) {
        try! realm.write {
            realm.delete(items)
        }
    }

    func deleteAll() {
        let objects = realm.objects(Transaction.self)
        try! realm.write {
            realm.delete(objects)
        }
    }
}
