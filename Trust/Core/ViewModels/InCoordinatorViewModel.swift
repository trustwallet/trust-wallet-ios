// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct InCoordinatorViewModel {

    let config: Config
    let preferences: PreferencesController

    init(
        config: Config,
        preferences: PreferencesController = PreferencesController()
    ) {
        self.config = config
        self.preferences = preferences
    }

    var tokensAvailable: Bool {
        switch config.server {
        case .main, .classic, .kovan, .ropsten, .rinkeby, .poa, .sokol, .custom: return true
        case .callisto: return false
        }
    }

    var canActivateDebugMode: Bool {
        return config.server.isTestNetwork
    }

    var initialTab: Tabs {
        guard preferences.get(for: .showTokensOnLaunch) else {
            return .transactions
        }
        return .tokens
    }
}
