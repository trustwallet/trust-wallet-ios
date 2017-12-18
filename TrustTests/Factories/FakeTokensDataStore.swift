// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import RealmSwift

class FakeTokensDataStore: TokensDataStore {
    convenience init() {
        let configuration = Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealmTest")
        self.init(session: .make(), configuration: configuration)
    }
}
