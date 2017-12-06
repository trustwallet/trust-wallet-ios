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
    let decimals: String?

    enum CodingKeys: String, CodingKey {
        case title
        case from
        case to
        case contract
        case type
        case value = "new_value"
        case symbol
        case decimals
    }
}
