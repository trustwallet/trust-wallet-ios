// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JSONRPCKit

struct GetBlockByNumberRequest: JSONRPCKit.Request {
    typealias Response = AnyObject

    let block: String
    let includeTransactions: Bool

    var method: String {
        return "eth_getBlockByNumber"
    }

    var parameters: Any? {
        return [
            block,
            includeTransactions,
        ]
    }

    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? AnyObject {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
