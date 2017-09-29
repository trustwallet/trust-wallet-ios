// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust

extension Address {
    static func make(
        address: String = "0x123f681646d4a755815f9cb19e1acc8565a0c2ac"
    ) -> Address {
        return Address(
            address: address
        )
    }
}
