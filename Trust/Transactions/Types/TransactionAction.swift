// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum TransactionAction {
    case tokenTransfer(TokenTransfer)
    case unknown
}

extension TransactionAction {
    static func from(dict: [String: AnyObject]) -> TransactionAction {
        guard let type = dict["type"] as? String else { return .unknown  }
        let actionType = TransactionActionType(string: type)
        switch actionType {
        case .tokenTransfer:
            let token = Token(
                address: Address(address: ""),
                name: dict["name"] as? String ?? "",
                symbol: dict["symbol"] as? String ?? "",
                totalSupply: dict["totalSupply"] as? String ?? "",
                balance: dict["balance"] as? Double ?? 0,
                decimals: dict["decimals"] as? Int64 ?? 0
            )
            let tokenTransfer = TokenTransfer(
                value: dict["value"] as? String ?? "",
                from: dict["from"] as? String ?? "",
                to: dict["to"] as? String ?? "",
                token: token
            )
            return TransactionAction.tokenTransfer(tokenTransfer)
        case .unknown:
            return .unknown
        }
    }
}
