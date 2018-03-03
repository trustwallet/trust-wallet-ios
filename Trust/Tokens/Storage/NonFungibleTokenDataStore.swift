// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import RealmSwift

class NonFungibleTokenDataStore {
    var nonFungibleTokens: Results<NonFungibleTokenObject> {
        return realm.objects(NonFungibleTokenObject.self).sorted(byKeyPath: "type", ascending: true)
    }
    var nonFungibleObjects: [NonFungibleTokenObject] {
        return realm.objects(NonFungibleTokenObject.self).map { $0 }
    }
    let config: Config
    let realm: Realm
    init(
        realm: Realm,
        config: Config
        ) {
        self.config = config
        self.realm = realm
    }
    func add(tokens: [NonFungibleTokenObject]) {
        realm.beginWrite()
        realm.add(tokens, update: true)
        try! realm.commitWrite()
    }
    func delete(tokens: [NonFungibleTokenObject]) {
        realm.beginWrite()
        realm.delete(tokens)
        try! realm.commitWrite()
    }
    func deleteAll() {
        try! realm.write {
            realm.delete(realm.objects(NonFungibleTokenObject.self))
        }
    }
}
