// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust

class FakeGetBalanceCoordinator: TokensBalanceService {
    convenience init() {
        self.init(web3: Web3Swift())
    }
}
