// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct Address {

    let address: String

    init(address: String) {
        self.address = address.lowercased()
    }
}

extension Address: Equatable {
    static func == (lhs: Address, rhs: Address) -> Bool {
        return lhs.address == rhs.address
    }
}
