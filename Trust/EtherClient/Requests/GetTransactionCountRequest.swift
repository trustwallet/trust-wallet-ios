// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JSONRPCKit

struct GetTransactionCountRequest: JSONRPCKit.Request {
    typealias Response = Int64

    let address: String

    var method: String {
        return "eth_getTransactionCount"
    }

    var parameters: Any? {
        return [
            address,
            "latest",
        ]
    }

    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? String {
            let value = BInt(hex: response.drop0x).dec
            return Int64(value) ?? 0
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
