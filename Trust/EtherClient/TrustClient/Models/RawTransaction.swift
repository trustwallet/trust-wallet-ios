// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct RawTransactionResponse: Decodable {
    let docs: [RawTransaction]
}

struct RawTransaction: Decodable {
    let _id: String
    let blockNumber: Int64
    let timeStamp: String
    let nonce: Int64
    let from: String
    let to: String
    let value: String
    let gas: String
    let gasPrice: String
    let input: String
    let gasUsed: String
}

extension Transaction {
    static func from(chainID: Int, owner: Address, transaction: RawTransaction) -> Transaction {
        let state: TransactionState = {
            return .completed
        }()
        return Transaction(
            id: transaction._id,
            owner: owner.address,
            chainID: chainID,
            state: state,
            blockNumber: transaction.blockNumber,
            from: transaction.from,
            to: transaction.to,
            value: transaction.value,
            gas: transaction.gas,
            gasPrice: transaction.gasPrice,
            gasUsed: transaction.gasUsed,
            nonce: String(transaction.nonce),
            date: NSDate(timeIntervalSince1970: TimeInterval(transaction.timeStamp) ?? 0) as Date,
            actionJSON: ""
        )
    }
}
