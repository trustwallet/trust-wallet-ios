// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import RealmSwift

extension Realm {
    static func fake() -> Realm {
        return try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))
    }
}
