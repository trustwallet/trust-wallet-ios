// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust
import RealmSwift

extension Realm {
    static func make() -> Realm {
        return try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))
    }
}
