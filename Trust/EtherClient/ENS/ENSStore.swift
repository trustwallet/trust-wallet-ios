// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import RealmSwift

struct ENSStore {
    var records: Results<ENSRecord> {
        return realm.objects(ENSRecord.self)
    }

    let realm: Realm

    init(realm: Realm) {
        self.realm = realm
    }

    func add(record: ENSRecord) {
        try? realm.write {
            realm.add([record], update: true)
        }
    }

    func removeAll() {
        try? realm.write {
            realm.delete(records)
        }
    }
}
