// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore

struct SentTransaction {
    let id: String
    let original: SignTransaction
}

extension SentTransaction {
    static func from(from: Address, transaction: SentTransaction) -> Transaction {
        return Transaction(
            id: transaction.id,
            blockNumber: 0,
            from: from.description,
            to: transaction.original.to?.description ?? "",
            value: transaction.original.value.description,
            gas: transaction.original.gasLimit.description,
            gasPrice: transaction.original.gasPrice.description,
            gasUsed: "",
            nonce: String(transaction.original.nonce),
            date: Date(),
            localizedOperations: [],
            state: .pending
        )
    }
}
