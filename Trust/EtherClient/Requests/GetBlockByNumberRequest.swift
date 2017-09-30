// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JSONRPCKit

struct GetBlockByNumberRequest: JSONRPCKit.Request {
    typealias Response = Block

    let block: String
    let includeTransactions: Bool = true

    var method: String {
        return "eth_getBlockByNumber"
    }

    var parameters: Any? {
        return [
            "pending",
            includeTransactions,
        ]
    }

    func response(from resultObject: Any) throws -> Response {
        if
            let response = resultObject as? [String: AnyObject],
            let block: Block = .from(json: response) {
            return block
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
