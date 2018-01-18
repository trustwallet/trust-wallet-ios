// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct PushDevice: Encodable {
    let deviceID: String
    let token: String
    let wallets: [String]
}
