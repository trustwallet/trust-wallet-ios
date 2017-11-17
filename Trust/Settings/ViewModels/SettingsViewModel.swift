// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct SettingsViewModel {

    private let isDebug: Bool

    init(
        isDebug: Bool = false
    ) {
        self.isDebug = isDebug
    }

    var servers: [String] {
        if isDebug {
            return [
                RPCServer.main.name,
                RPCServer.kovan.name,
                RPCServer.oraclesTest.name,
            ]
        }
        return [
            RPCServer.main.name,
            RPCServer.kovan.name,
        ]
    }
}
