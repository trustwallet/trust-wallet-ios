// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import KeychainSwift

class FakeEtherKeystore: EtherKeystore {
    convenience init() {
        self.init(
            keychain: KeychainSwift(keyPrefix: "fake"),
            keyStoreSubfolder: "/" + NSUUID().uuidString
        )
    }
}
