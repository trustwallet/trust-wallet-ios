// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct OpenseaArrayResponse<T: Decodable>: Decodable {
    let assets: [T]
}
