// Copyright SIX DAY LLC. All rights reserved.

import Foundation

protocol JSONable {
    var dict: [String: Any] { get }
}

struct PushDevice: JSONable {

    let deviceID: String
    let token: String
    let wallets: [String]

    var dict: [String: Any] {
        return [
            "deviceID": deviceID,
            "token": token,
            "wallets": wallets,
        ]
    }
}
