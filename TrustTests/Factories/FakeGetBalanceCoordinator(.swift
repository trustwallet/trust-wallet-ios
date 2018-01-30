// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust

class FakeGetBalanceCoordinator: GetBalanceCoordinator {
    convenience init() {
        self.init(web3: Web3Swift())
    }
}
