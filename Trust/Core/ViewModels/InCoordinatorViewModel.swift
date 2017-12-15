// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct InCoordinatorViewModel {

    let config: Config

    init(config: Config) {
        self.config = config
    }

    var tokensAvailable: Bool {
        switch config.server {
        case .main: return true
        case .kovan, .ropsten, .poa, .poaTest: return false
        }
    }

    var exchangeAvailable: Bool {
        switch config.server {
        case .main, .ropsten, .poa, .poaTest: return false
        case .kovan: return config.isDebugEnabled
        }
    }

    var canActivateDebugMode: Bool {
        return config.server.isTestNetwork
    }
}
