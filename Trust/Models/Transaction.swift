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
