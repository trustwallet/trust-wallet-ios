// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JSONRPCKit

struct GetTransactionRequest: JSONRPCKit.Request {
    typealias Response = String

    let address: String

    var method: String {
        return "eth_getTransactionByHash"
    }

    var parameters: Any? {
        return [address]
    }

    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? Response {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
