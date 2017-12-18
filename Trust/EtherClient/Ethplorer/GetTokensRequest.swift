// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import APIKit

struct GetTokensRequest: APIKit.Request {
    typealias Response = [Token]

    let address: String

    var baseURL: URL {
        let config = Config()
        return config.ethplorerURL
    }

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "getAddressInfo/\(address)"
    }

    var parameters: Any? {
        return [
            "apiKey": "freekey",
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        if
            let objectJSON = object as? [String: AnyObject],
            let tokensJSON = objectJSON["tokens"] as? [[String: AnyObject]] {
            return tokensJSON.map { Token.from(address: address, json: $0) }.filter { !$0.address.address.isEmpty }
        }
        return []
    }
}
