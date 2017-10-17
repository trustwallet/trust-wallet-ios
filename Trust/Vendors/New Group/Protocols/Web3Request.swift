// Copyright SIX DAY LLC. All rights reserved.

import Foundation

protocol Web3Request {
    associatedtype Response: Decodable
    var type: Web3RequestType { get }
}
