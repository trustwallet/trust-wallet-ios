// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import JSONRPCKit

struct BalanceRequest: JSONRPCKit.Request {
    typealias Response = Balance
    
    let address: String
    
    var method: String {
        return "eth_getBalance"
    }
    
    var parameters: Any? {
        return [address, "latest"]
    }
    
    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? String {
            return Balance(value: BInt(hex: response.drop0x))
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
