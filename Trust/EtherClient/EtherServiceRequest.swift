// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import APIKit
import JSONRPCKit

struct EtherServiceRequest<Batch: JSONRPCKit.Batch>: APIKit.Request {
    let batch: Batch

    typealias Response = Batch.Responses

    var baseURL: URL {
        let config = Config()
        return config.rpcURL
    }

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "/"
    }

    var parameters: Any? {
        return batch.requestObject
    }

    func intercept(urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.timeoutInterval = 5.0
        return urlRequest
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return try batch.responses(from: object)
    }
}
