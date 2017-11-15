// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct RawTransaction: Decodable {
    let hash: String
    let blockNumber: Int
    let timeStamp: String
    let nonce: Int
    let from: String
    let to: String
    let value: String
    let gas: String
    let gasPrice: String
    let input: String
    let gasUsed: String

    enum CodingKeys: String, CodingKey {
        case hash = "_id"
        case blockNumber
        case timeStamp
        case nonce
        case from
        case to
        case value
        case gas
        case gasPrice
        case input
        case gasUsed
        case operations
    }

    let operations: [Operation]
}

extension Transaction {
    static func from(chainID: Int, owner: Address, transaction: RawTransaction) -> Transaction {
        return Transaction(
            id: transaction.hash,
            owner: owner.address,
            chainID: chainID,
            blockNumber: transaction.blockNumber,
            from: transaction.from,
            to: transaction.to,
            value: transaction.value,
            gas: transaction.gas,
            gasPrice: transaction.gasPrice,
            gasUsed: transaction.gasUsed,
            nonce: String(transaction.nonce),
            date: NSDate(timeIntervalSince1970: TimeInterval(transaction.timeStamp) ?? 0) as Date,
            isError: false
        )
    }
}
