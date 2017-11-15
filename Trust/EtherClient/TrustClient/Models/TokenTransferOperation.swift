// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct TokenTransferOperation: Decodable {
    let from: String
    let to: String
    let type: OperationType
    let value: String
    let contract: ERC20Contract
}
