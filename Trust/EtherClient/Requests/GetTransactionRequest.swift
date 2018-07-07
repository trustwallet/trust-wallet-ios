// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import JSONRPCKit
import TrustCore

struct GetTransactionRequest: JSONRPCKit.Request {
    typealias Response = PendingTransaction

    let hash: String

    var method: String {
        return "eth_getTransactionByHash"
    }

    var parameters: Any? {
        return [hash]
    }

    func response(from resultObject: Any) throws -> Response {
        guard
            let dict = resultObject as? [String: AnyObject],
            let transaction = PendingTransaction.from(dict)
        else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
        return transaction
    }
}
