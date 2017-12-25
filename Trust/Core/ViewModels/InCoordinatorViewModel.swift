// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct InCoordinatorViewModel {

    let config: Config

    init(config: Config) {
        self.config = config
    }

    var tokensAvailable: Bool {
        switch config.server {
        case .main, .kovan, .ropsten, .poa: return true
        }
    }

    var browserAvailable: Bool {
        return isDebug
    }

    var exchangeAvailable: Bool {
        switch config.server {
        case .main, .ropsten, .poa: return false
        case .kovan: return false //config.isDebugEnabled
        }
    }

    var canActivateDebugMode: Bool {
        return config.server.isTestNetwork
    }
}
