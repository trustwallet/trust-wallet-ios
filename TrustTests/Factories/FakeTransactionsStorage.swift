// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import RealmSwift

class FakeTransactionsStorage: TransactionsStorage {
    convenience init(_ current: Account = .make(address: Address(address: "0x1")), chainID: Int = -1) {
        let configuration = Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm")
        self.init(configuration: configuration)
    }
}
