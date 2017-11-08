// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct EtherscanArrayResponse<T: Decodable>: Decodable {
    let result: [T]
}
