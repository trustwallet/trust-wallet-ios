// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust
import TrustKeystore
import KeychainSwift
import Result

class FakeEtherKeystore: EtherKeystore {
    convenience init() {
        let uniqueString = NSUUID().uuidString
        self.init(
            keychain: KeychainSwift(keyPrefix: "fake" + uniqueString),
            keysSubfolder: "/keys" + uniqueString,
            userDefaults: UserDefaults.test,
            storage: FakeWalletStorage()
        )
    }

    override func createAccount(with password: String, completion: @escaping (Result<Account, KeystoreError>) -> Void) {
        completion(.success(.make()))
    }
}
