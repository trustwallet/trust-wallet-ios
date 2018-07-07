// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust
import TrustCore

extension Address {
    static func make(
        address: String = "0x0000000000000000000000000000000000000001"
    ) -> Address {
        return Address(
            string: address
        )!
    }
}
