// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct Block {
    let number: String
    let transactions: [ParsedTransaction]
}

extension Block {
    static func from(json: [String: AnyObject]) -> Block? {
        if
            let transactionsJSON = json["transactions"] as? [[String: AnyObject]] {
            let transactions: [ParsedTransaction] = transactionsJSON.map({ .from(json: $0) })
            return Block(
                number: "1",
                transactions: transactions
            )
        }
        return nil
    }
}
