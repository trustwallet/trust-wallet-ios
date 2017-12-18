// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation

struct ParsedTransaction {
    let blockHash: String
    let blockNumber: String
    let transactionIndex: String
    let confirmations: String
    let cumulativeGasUsed: String
    let from: String
    let to: String
    let gas: String
    let gasPrice: String
    let gasUsed: String
    let hash: String
    let value: String
    let nonce: String
    let timestamp: String
    let isError: Bool
}

extension ParsedTransaction {
    static func from(json: [String: AnyObject]) -> ParsedTransaction {
        let blockHash = json["blockHash"] as? String ?? ""
        let blockNumber = json["blockNumber"] as? String ?? ""
        let transactionIndex = json["transactionIndex"] as? String ?? ""
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
            transactionIndex: transactionIndex,
            confirmations: confirmation,
            cumulativeGasUsed: cumulativeGasUsed,
            from: from,
            to: to,
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

extension ParsedTransaction {
    static func from(block: ParsedBlock, transaction: [String: AnyObject]) -> ParsedTransaction {
        let blockHash = transaction["blockHash"] as? String ?? ""
        let blockNumber = transaction["blockNumber"] as? String ?? ""
        let transactionIndex = transaction["transactionIndex"] as? String ?? "0"
        let confirmation = transaction["confirmations"] as? String ?? "0"
        let cumulativeGasUsed = transaction["cumulativeGasUsed"] as? String ?? "0"
        let from = transaction["from"] as? String ?? ""
        let to = transaction["to"] as? String ?? ""
        let gas = transaction["gas"] as? String ?? "0"
        let gasPrice = transaction["gasPrice"] as? String ?? "0"
        let gasUsed = transaction["gasUsed"] as? String ?? "0"
        let hash = transaction["hash"] as? String ?? ""
        let isError = Bool(transaction["isError"] as? String ?? "") ?? false
        let timestamp = block.timestamp
        let value = transaction["value"] as? String ?? "0"
        let nonce = transaction["nonce"] as? String ?? "0"
        return ParsedTransaction(
            blockHash: blockHash,
            blockNumber: BigInt(blockNumber.drop0x, radix: 16)?.description ?? "",
            transactionIndex: BigInt(transactionIndex.drop0x, radix: 16)?.description ?? "",
            confirmations: confirmation,
            cumulativeGasUsed: BigInt(cumulativeGasUsed.drop0x, radix: 16)?.description ?? "",
            from: from,
            to: to,
            gas: BigInt(gas.drop0x, radix: 16)?.description ?? "",
            gasPrice: BigInt(gasPrice.drop0x, radix: 16)?.description ?? "",
            gasUsed: BigInt(gasUsed.drop0x, radix: 16)?.description ?? "",
            hash: hash,
            value: BigInt(value.drop0x, radix: 16)?.description ?? "",
            nonce: BigInt(nonce.drop0x, radix: 16)?.description ?? "",
            timestamp: BigInt(timestamp.drop0x, radix: 16)?.description ?? "",
            isError: isError
        )
    }
}

extension Transaction {
    static func from(
        chainID: Int,
        owner: Address,
        transaction: ParsedTransaction
    ) -> Transaction {
        return Transaction(
            id: transaction.hash,
            owner: owner.address,
            blockNumber: Int(transaction.blockNumber) ?? 0,
            from: transaction.from,
            to: transaction.to,
            value: transaction.value,
            gas: transaction.gas,
            gasPrice: transaction.gasPrice,
            gasUsed: transaction.gasUsed,
            nonce: transaction.nonce,
            date: NSDate(timeIntervalSince1970: TimeInterval(transaction.timestamp) ?? 0) as Date,
            isError: false,
            localizedOperations: []
        )
    }
}
