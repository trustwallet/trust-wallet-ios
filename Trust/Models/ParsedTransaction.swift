// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum TransactionDirection {
    case incoming
    case outgoing
}

struct ParsedTransaction {

    let blockHash: String
    let blockNumber: String
    let confirmations: String
    let cumulativeGasUsed: String
    let from: String
    let to: String
    let owner: String
    let gas: String
    let gasPrice: String
    let gasUsed: String
    let hash: String
    let value: String
    let nonce: String
    let timestamp: String
    let isError: Bool

    var time: Date {
        return NSDate(timeIntervalSince1970: TimeInterval(timestamp) ?? 0) as Date
    }
}

extension ParsedTransaction {
    static func from(address: String, json: [String: AnyObject]) -> ParsedTransaction {
        let blockHash = json["blockHash"] as? String ?? ""
        let blockNumber = json["blockNumber"] as? String ?? ""
        let confirmation = json["confirmations"] as? String ?? ""
        let cumulativeGasUsed = json["cumulativeGasUsed"] as? String ?? ""
        let from = json["from"] as? String ?? ""
        let to = json["to"] as? String ?? ""
        let gas = json["gas"] as? String ?? ""
        let gasPrice = json["gasPrice"] as? String ?? ""
        let gasUsed = json["gasUsed"] as? String ?? ""
        let hash = json["hash"] as? String ?? ""
        let isError = Bool(json["isError"] as? String ?? "") ?? false
        let timestamp = (json["timeStamp"] as? String ?? "")
        let value = (json["value"] as? String ?? "")
        let nonce = (json["nonce"] as? String ?? "")
        return ParsedTransaction(
            blockHash: blockHash,
            blockNumber: blockNumber,
            confirmations: confirmation,
            cumulativeGasUsed: cumulativeGasUsed,
            from: from,
            to: to,
            owner: address,
            gas: gas,
            gasPrice: gasPrice,
            gasUsed: gasUsed,
            hash: hash,
            value: value,
            nonce: nonce,
            timestamp: timestamp,
            isError: isError
        )
    }
}
