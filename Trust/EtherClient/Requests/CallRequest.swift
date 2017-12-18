// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JSONRPCKit

struct CallRequest: JSONRPCKit.Request {
    typealias Response = String

    let to: String
    let data: String

    var method: String {
        return "eth_call"
    }

    var parameters: Any? {
        return [["to": to, "data": data], "latest"]
    }

    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? Response {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
