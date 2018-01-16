// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JSONRPCKit
import TrustKeystore

struct EstimateGasRequest: JSONRPCKit.Request {
    typealias Response = String

    let to: Address?
    let data: Data

    var method: String {
        return "eth_estimateGas"
    }

    var parameters: Any? {
        return [["to": to, "data": data.hexEncoded]]
    }

    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? Response {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
