// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import TrustCore

extension Address {
    static func make(
        address: String = "0x1000000000000000000000000000000000000000"
    ) -> Address {
        return Address(
            string: address
        )!
    }
}
