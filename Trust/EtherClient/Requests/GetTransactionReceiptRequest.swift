// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import JSONRPCKit
import TrustCore
import BigInt

struct TransactionReceipt: Encodable {
    let gasUsed: String
    let status: Bool
}

struct GetTransactionReceiptRequest: JSONRPCKit.Request {
    typealias Response = TransactionReceipt

    let hash: String
    var method: String {
        return "eth_getTransactionReceipt"
    }
    var parameters: Any? {
        return [hash]
    }

    func response(from resultObject: Any) throws -> Response {
        guard
            let dict = resultObject as? [String: AnyObject],
            let gasUsedString = dict["gasUsed"] as? String,
            let statusString = dict["status"] as? String,
            let gasUsed = BigInt(gasUsedString.drop0x, radix: 16)
            else {
                throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
        return TransactionReceipt(
            gasUsed: gasUsed.description,
            status: statusString == "0x1" ? true : false
        )
    }
}
