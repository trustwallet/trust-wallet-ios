// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import BigInt

extension UnconfirmedTransaction {
    static func make(
        transferType: TransferType = .ether(destination: .none),
        value: BigInt = BigInt(1),
        address: Address = .make(),
        account: Account = .make(),
        chainID: Int = 1,
        data: Data = Data()
    ) -> UnconfirmedTransaction {
        return UnconfirmedTransaction(
            transferType: transferType,
            value: value,
            address: address,
            account: account,
            chainID: chainID,
            data: data
        )
    }
}
