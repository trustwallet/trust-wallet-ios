// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JSONRPCKit

struct GetCodeRequest: JSONRPCKit.Request {
    typealias Response = String

    var method: String {
        return "eth_getCode"
    }

    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? Response {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
