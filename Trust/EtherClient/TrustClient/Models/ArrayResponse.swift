// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ArrayResponse<T: Decodable>: Decodable {
    let docs: [T]
}
