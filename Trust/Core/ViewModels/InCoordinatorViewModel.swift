// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct InCoordinatorViewModel {

    let config: Config

    init(config: Config) {
        self.config = config
    }

    var tokensAvailable: Bool {
        switch config.server {
        case .main, .kovan, .ropsten, .poa, .poaTest: return true
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
