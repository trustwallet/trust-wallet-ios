// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore

struct SentTransaction {
    let id: String
    let original: SignTransaction
    let data: Data
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
            nonce: Int(transaction.original.nonce),
            date: Date(),
            localizedOperations: [transaction.original.localizedObject].compactMap { $0 },
            state: .pending
        )
    }
}
