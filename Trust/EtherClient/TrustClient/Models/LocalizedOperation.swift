// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct LocalizedOperation: Decodable {
    let title: String
    let from: String
    let to: String
    let contract: String?
    let type: OperationType
    let value: String
    let symbol: String?
}
