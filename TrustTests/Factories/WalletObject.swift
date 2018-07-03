// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust

extension WalletObject {
    static func make(
        id: String = "1"
    ) -> WalletObject {
        let object = WalletObject()
        object.id = id
        return object
    }
}
