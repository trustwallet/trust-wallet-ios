// Copyright DApps Platform Inc. All rights reserved.

import Foundation

enum PaymentFlow {
    case send(type: Transfer)
    case request(TokenObject)
}
