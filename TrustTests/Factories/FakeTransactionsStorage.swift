// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import RealmSwift

class FakeTransactionsStorage: TransactionsStorage {
    convenience init() {
        let configuration = Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm")
        self.init(configuration: configuration)
    }
}
