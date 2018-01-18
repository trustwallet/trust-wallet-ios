// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import TrustKeystore
import BigInt

extension UnconfirmedTransaction {
    static func make(
        transferType: TransferType = .ether(destination: .none),
        value: BigInt = BigInt(1),
        to: Address = .make(),
        data: Data = Data()
    ) -> UnconfirmedTransaction {
        return UnconfirmedTransaction(
            transferType: transferType,
            value: value,
            to: to,
            data: data
        )
    }
}
