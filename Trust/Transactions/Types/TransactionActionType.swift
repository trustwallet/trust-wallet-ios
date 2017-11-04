// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum TransactionActionType: String {
    case tokenTransfer = "token_transfer"
    case unknown

    init(string: String) {
        self = TransactionActionType(rawValue: string) ?? .unknown
    }
}
