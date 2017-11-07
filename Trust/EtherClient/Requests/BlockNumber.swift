// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JSONRPCKit

struct BlockNumberRequest: JSONRPCKit.Request {
    typealias Response = Int

    var method: String {
        return "eth_blockNumber"
    }

    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? String {
            return Int(BInt(hex: response.drop0x).dec) ?? 0
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
