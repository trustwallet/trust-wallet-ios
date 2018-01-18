// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import TrustKeystore

extension Address {
    static func make(
        address: String = "0x1000000000000000000000000000000000000000"
    ) -> Address {
        return Address(
            string: address
        )!
    }
}
