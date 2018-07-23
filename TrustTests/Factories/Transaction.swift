// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust
import TrustCore

extension Trust.Transaction {
    static func make(
        id: String = "0x1",
        blockNumber: Int = 1,
        from: String = "0x0000000000000000000000000000000000000001",
        to: String = "0x1",
        value: String = "1",
        gas: String = "0x1",
        gasPrice: String = "0x1",
        gasUsed: String = "0x1",
        nonce: Int = 0,
        date: Date = Date(),
        coin: Coin = .ethereum,
        localizedOperations: [LocalizedOperationObject] = [],
        state: TransactionState = .completed
    ) -> Trust.Transaction {
        return Trust.Transaction(
            id: id,
            blockNumber: blockNumber,
            from: from,
            to: to,
            value: value,
            gas: gas,
            gasPrice: gasPrice,
            gasUsed: gasUsed,
            nonce: nonce,
            date: date,
            coin: coin,
            localizedOperations: localizedOperations,
            state: state
        )
    }
}
