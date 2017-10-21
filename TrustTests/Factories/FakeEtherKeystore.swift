// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import KeychainSwift

class FakeEtherKeystore: EtherKeystore {
    convenience init() {
        let uniqueString = NSUUID().uuidString
        self.init(
            keychain: KeychainSwift(keyPrefix: "fake" + uniqueString),
            keyStoreSubfolder: "/" + uniqueString
        )
    }
}
