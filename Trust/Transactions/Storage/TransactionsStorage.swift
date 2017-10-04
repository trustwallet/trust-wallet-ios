// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class TransactionsStorage {

    let realm: Realm

    init(
        configuration: Realm.Configuration = .defaultConfiguration
    ) {
        self.realm = try! Realm(configuration: configuration)
    }

    var count: Int {
        return realm.objects(Transaction.self).count
    }

    var objects: [Transaction] {
        return realm.objects(Transaction.self).sorted(byKeyPath: "date", ascending: true).filter { _ in
            return true
        }
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
