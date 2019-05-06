// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import IPOS
import RealmSwift

extension Realm {
    static func make() -> Realm {
        return try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))
    }
}
