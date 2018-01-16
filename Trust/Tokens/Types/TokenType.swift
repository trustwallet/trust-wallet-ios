// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum TokenType: Int {
    case ether
    case token
    case unknown

    init(int: Int) {
        self = TokenType(rawValue: int) ?? .unknown
    }
}
