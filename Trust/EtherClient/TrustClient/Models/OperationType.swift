// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum OperationType: String {
    case tokenTransfer = "token_transfer"
    case unknown

    init(string: String) {
        self = OperationType(rawValue: string) ?? .unknown
    }
}

extension OperationType: Decodable { }
