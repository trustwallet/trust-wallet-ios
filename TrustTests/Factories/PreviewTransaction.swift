// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt
@testable import Trust
import TrustCore
import TrustKeystore

extension PreviewTransaction {
    static func make(
        account: Account = .make(),
        address: Address = EthereumAddress.zero
    ) -> PreviewTransaction {
        return PreviewTransaction(
            value: BigInt(),
            account: account,
            address: EthereumAddress.zero,
            contract: EthereumAddress.zero,
            nonce: BigInt(),
            data: Data(),
            gasPrice: BigInt(),
            gasLimit: BigInt(),
            transfer: Transfer.init(server: .make(), type: .token(.make()))
        )
    }
}
