// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import IPOS

extension WalletObject {
    static func make(
        id: String = "1"
    ) -> WalletObject {
        let object = WalletObject()
        object.id = id
        return object
    }
}
