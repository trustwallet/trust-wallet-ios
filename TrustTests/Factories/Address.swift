// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust

extension Address {
    static func make(
        address: String = "0x1"
    ) -> Address {
        return Address(
            address: address
        )
    }
}
