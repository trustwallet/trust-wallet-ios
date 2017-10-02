// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ParsedBlock {
    let number: String
    let timestamp: String
}

struct Block {
    let number: String
    let timestamp: String
    let transactions: [ParsedTransaction]
}

extension Block {
    static func from(json: [String: AnyObject]) -> Block? {
        if
            let transactionsJSON = json["transactions"] as? [[String: AnyObject]] {

            let number = json["number"] as? String ?? ""
            let timestamp = json["timestamp"] as? String ?? ""

            let block = ParsedBlock(
                number: number,
                timestamp: timestamp
            )

            let transactions: [ParsedTransaction] = transactionsJSON.map { .from(block: block, transaction: $0) }

            return Block(
                number: number,
                timestamp: timestamp,
                transactions: transactions
            )
        }
        return nil
    }
}
