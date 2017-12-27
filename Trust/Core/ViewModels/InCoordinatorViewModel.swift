// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct InCoordinatorViewModel {

    let config: Config

    init(config: Config) {
        self.config = config
    }

    var tokensAvailable: Bool {
        switch config.server {
        case .main, .classic, .kovan, .ropsten, .poa: return true
        }
    }

    var browserAvailable: Bool {
        return true //isDebug
    }

    var exchangeAvailable: Bool {
        switch config.server {
        case .main, .classic, .ropsten, .poa: return false
        case .kovan: return false //config.isDebugEnabled
        }
    }

    var canActivateDebugMode: Bool {
        return config.server.isTestNetwork
    }
}
