// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum Method: String, Decodable {
    //case getAccounts
    case sendTransaction
    case signTransaction
    case signPersonalMessage
    case signMessage
    case unknown

    init(string: String) {
        self = Method(rawValue: string) ?? .unknown
    }
}
