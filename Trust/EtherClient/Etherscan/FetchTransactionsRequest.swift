// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import APIKit

struct FetchTransactionsRequest: APIKit.Request {
    typealias Response = [ParsedTransaction]

    let address: String
    let startBlock: String
    let endBlock: String

    init(address: String, startBlock: String = "0", endBlock: String = "99999999") {
        self.address = address
        self.startBlock = startBlock
        self.endBlock = endBlock
    }

    var baseURL: URL {
        let config = Config()
        return config.etherScanAPIURL
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
            "startblock": startBlock,
            "endblock": endBlock,
            "sort": "asc",
            "apikey": "7V8AMAVQWKNAZHZG8ARYB9SQWWKBBDA7S8",
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        if
            let objectJSON = object as? [String: AnyObject],
            let transactionJSON = objectJSON["result"] as? [[String: AnyObject]] {
            return transactionJSON.map { .from(json: $0) }
        }
        return []
    }
}
