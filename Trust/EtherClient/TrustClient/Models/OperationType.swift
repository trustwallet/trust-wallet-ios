// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum OperationType: String {
    case tokenTransfer = "token_transfer"
}

extension OperationType: Decodable { }
