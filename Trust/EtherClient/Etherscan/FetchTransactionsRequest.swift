// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import APIKit

struct FetchTransactionsRequest: APIKit.Request {
    typealias Response = [Transaction]

    let address: String

    var baseURL: URL {
        let config = Config()
        return config.etherScanURL
    }

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return ""
    }

    var parameters: Any? {
        return [
            "module": "account",
            "action": "txlist",
            "address": address,
            "startblock": "0",
            "endblock": "99999999",
            "sort": "asc",
            "apikey": "7V8AMAVQWKNAZHZG8ARYB9SQWWKBBDA7S8",
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        if
            let objectJSON = object as? [String: AnyObject],
            let transactionJSON = objectJSON["result"] as? [[String: AnyObject]] {
            return transactionJSON.map { .from(address: address.lowercased(), json: $0) }
        }
        return []
    }
}
