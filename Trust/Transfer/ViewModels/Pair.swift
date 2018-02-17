// Copyright SIX DAY LLC. All rights reserved.

import UIKit

struct Pair {
    let left: String
    let right: String
    func swapPair() -> Pair {
        return Pair(left: right, right: left)
    }
}
