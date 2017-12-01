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
        let list: [RPCServer] = {
            if isDebug {
                return [
                    RPCServer.main,
                    RPCServer.kovan,
                    RPCServer.oraclesTest,
                ]
            }
            return [
                RPCServer.main,
                RPCServer.kovan,
            ]
        }()
        return list.map { $0.name }
    }
}
