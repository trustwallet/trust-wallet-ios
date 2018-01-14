// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JSONRPCKit

struct EstimateGasRequest: JSONRPCKit.Request {
    typealias Response = String

    let to: String
    let data: Data

    var method: String {
        return "eth_estimateGas"
    }

    var parameters: Any? {
        return [["to": to, "data": data.hexEncoded], "latest"]
    }
    
    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? Response {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
