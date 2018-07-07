// Copyright DApps Platform Inc. All rights reserved.

import BigInt
import Foundation
import JSONRPCKit

struct BlockNumberRequest: JSONRPCKit.Request {
    typealias Response = Int

    var method: String {
        return "eth_blockNumber"
    }

    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? String, let value = BigInt(response.drop0x, radix: 16) {
            return numericCast(value)
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
