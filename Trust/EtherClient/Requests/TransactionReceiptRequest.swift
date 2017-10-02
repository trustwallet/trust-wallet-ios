// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JSONRPCKit

struct TransactionReceiptRequest: JSONRPCKit.Request {
    typealias Response = ParsedTransaction

    let hash: String

    var method: String {
        return "eth_getTransactionReceipt"
    }

    var parameters: Any? {
        return [
            hash,
        ]
    }

    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? [String: AnyObject] {
            return ParsedTransaction.from(json: response)
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
