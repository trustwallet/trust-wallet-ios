// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust

extension Transaction {
    static func make(
        id: String = "0x1",
        owner: String = "0x1",
        chainID: Int = -1,
        state: TransactionState = .pending,
        blockNumber: String = "0x1",
        transactionIndex: String = "0x1",
        from: String = "0x1",
        to: String = "0x1",
        value: String = "1",
        gas: String = "0x1",
        gasPrice: String = "0x1",
        gasUsed: String = "0x1",
        confirmations: Int64 = 64,
        nonce: String = "0",
        date: Date = Date(),
        actionJSON: String = ""
    ) -> Transaction {
        return Transaction(
            id: id,
            owner: owner,
            chainID: chainID,
            state: state,
            blockNumber: blockNumber,
            transactionIndex: transactionIndex,
            from: from,
            to: to,
            value: value,
            gas: gas,
            gasPrice: gasPrice,
            gasUsed: gasUsed,
            confirmations: confirmations,
            nonce: nonce,
            date: date,
            actionJSON: actionJSON
        )
    }
}
