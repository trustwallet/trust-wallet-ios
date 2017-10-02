// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import APIKit

struct FetchTransactionsRequest: APIKit.Request {
    typealias Response = [EtherScanTransaction]

    let address: String
    let startBlock: String
    let endBlock: String

    init(address: String, startBlock: String = "0", endBlock: String = "99999999") {
        self.address = address
        self.startBlock = startBlock
        self.endBlock = endBlock
    }

    var baseURL: URL {
        let config = Config()
        return config.etherScanURL
    }

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return ""
    }

    var parameters: Any? {
        return [
            "module": "account",
            "action": "txlist",
            "address": address,
            "startblock": startBlock,
            "endblock": endBlock,
            "sort": "asc",
            "apikey": "7V8AMAVQWKNAZHZG8ARYB9SQWWKBBDA7S8",
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        if
            let objectJSON = object as? [String: AnyObject],
            let transactionJSON = objectJSON["result"] as? [[String: AnyObject]] {
            return transactionJSON.map { .from(json: $0) }
        }
        return []
    }
}

struct EtherScanTransaction {
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

extension EtherScanTransaction {
    static func from(json: [String: AnyObject]) -> EtherScanTransaction {
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
        return EtherScanTransaction(
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
