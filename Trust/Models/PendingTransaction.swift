// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation
import TrustKeystore

struct PendingTransaction: Decodable {
    let blockHash: String
    let blockNumber: String
    let from: String
    let to: String
    let gas: String
    let gasPrice: String
    let hash: String
    let value: String
    let nonce: String
}

extension PendingTransaction {
    static func from(_ transaction: [String: AnyObject]) -> PendingTransaction? {
        let blockHash = transaction["blockHash"] as? String ?? ""
        let blockNumber = transaction["blockNumber"] as? String ?? ""
        let gas = transaction["gas"] as? String ?? "0"
        let gasPrice = transaction["gasPrice"] as? String ?? "0"
        let hash = transaction["hash"] as? String ?? ""
        let value = transaction["value"] as? String ?? "0"
        let nonce = transaction["nonce"] as? String ?? "0"
        let from = transaction["from"] as? String ?? ""
        let to = transaction["to"] as? String ?? ""
        return PendingTransaction(
            blockHash: blockHash,
            blockNumber: BigInt(blockNumber.drop0x, radix: 16)?.description ?? "",
            from: from,
            to: to,
            gas: BigInt(gas.drop0x, radix: 16)?.description ?? "",
            gasPrice: BigInt(gasPrice.drop0x, radix: 16)?.description ?? "",
            hash: hash,
            value: BigInt(value.drop0x, radix: 16)?.description ?? "",
            nonce: BigInt(nonce.drop0x, radix: 16)?.description ?? ""
        )
    }
}

extension Transaction {
    static func from(
        transaction: PendingTransaction
    ) -> Transaction? {
        guard
            let from = Address(string: transaction.from) else {
                return .none
        }
        let to = Address(string: transaction.to)?.description ?? transaction.to
        return Transaction(
            id: transaction.hash,
            blockNumber: Int(transaction.blockNumber) ?? 0,
            from: from.description,
            to: to,
            value: transaction.value,
            gas: transaction.gas,
            gasPrice: transaction.gasPrice,
            gasUsed: "",
            nonce: transaction.nonce,
            date: Date(),
            localizedOperations: [],
            state: .pending
        )
    }
}
