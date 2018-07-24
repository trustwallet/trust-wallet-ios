// Copyright DApps Platform Inc. All rights reserved.

import Foundation

enum DeviceType: String, Encodable {
    case ios
    case android
}

struct PushDevice: Encodable {
    let deviceID: String
    let token: String
    let networks: [Int: [String]]
    let type: DeviceType = .ios
    let preferences: Preferences
}
