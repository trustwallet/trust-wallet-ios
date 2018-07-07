// Copyright DApps Platform Inc. All rights reserved.

import Foundation

enum PaymentFlow {
    case send(type: TransferType)
    case request(token: TokenObject)
}
