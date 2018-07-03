// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import RealmSwift

class FakeTransactionsStorage: TransactionsStorage {
    convenience init() {
        let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm" + UUID().uuidString))
        self.init(realm: realm, account: .make())
    }
}

class FakeWalletStorage: WalletStorage {
    convenience init() {
        let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm" + UUID().uuidString))
        self.init(realm: realm)
    }
}
