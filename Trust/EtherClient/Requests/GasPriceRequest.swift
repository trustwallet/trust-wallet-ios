// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import JSONRPCKit

struct GasPriceRequest: JSONRPCKit.Request {
    typealias Response = String

    var method: String {
        return "eth_gasPrice"
    }

    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? Response {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
