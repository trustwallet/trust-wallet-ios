// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation

enum TransactionDirection {
    case incoming
    case outgoing
}

struct Transaction {

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
    let value: BInt
    let timestamp: String
    let isError: Bool

    var amount: String {
        return EthereumConverter.from(value: value, to: .ether, minimumFractionDigits: 2)
    }

    var direction: TransactionDirection {
        if owner == from { return .outgoing }
        return .incoming
    }

    var state: TransactionState {
        if isError {
            return .error
        }
        return .completed
    }

    var time: Date {
        return NSDate(timeIntervalSince1970: TimeInterval(timestamp) ?? 0) as Date
    }
}

extension Transaction {
    static func from(address: String, json: [String: AnyObject]) -> Transaction {
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
        let hex = (json["value"] as? String ?? "")
        let value = BInt(hex)
        return Transaction(
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
            timestamp: timestamp,
            isError: isError
        )
    }
}
