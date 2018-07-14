// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust
import TrustCore

extension EthereumAddress {
    static func make(
        address: String = "0x0000000000000000000000000000000000000001"
    ) -> EthereumAddress {
        return EthereumAddress(
            string: address
        )!
    }
}
