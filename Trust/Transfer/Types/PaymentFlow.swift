// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum PaymentFlow {
    case send(destination: Address?)
    case request
}
