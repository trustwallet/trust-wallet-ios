// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import RealmSwift

class FakeTokensDataStore: TokensDataStore {
    convenience init() {
        let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealmTest"))
        let account: Wallet = .make()
        let config: Config = .make()
        let web3: Web3Swift = Web3Swift()
        self.init(realm: realm, account: account, config: config, web3: web3)
    }
}
