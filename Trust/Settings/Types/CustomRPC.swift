// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct CustomRPC {
    let chainID: Int
    let name: String
    let symbol: String
    let endpoint: String
}

extension CustomRPC: Equatable {
    static func == (lhs: CustomRPC, rhs: CustomRPC) -> Bool {
        return
            lhs.chainID == rhs.chainID &&
            lhs.name == rhs.name &&
            lhs.symbol == rhs.symbol &&
            lhs.endpoint == rhs.symbol
    }
}
