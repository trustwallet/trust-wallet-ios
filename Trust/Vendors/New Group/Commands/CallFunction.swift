// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct CallFunction: Web3Request {
    typealias Response = String
    let address: String
    var type: Web3RequestType {
        return .script(command: "")
    }
}
