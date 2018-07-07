// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust

class TokensCoordinatorTests: XCTestCase {
    
    func testRootViewController() {
        let coordinator = TokensCoordinator(
            navigationController: FakeNavigationController(),
            session: .make(),
            keystore: FakeKeystore(),
            tokensStorage: FakeTokensDataStore(),
            network: FakeTokensNetwork(
                provider: TrustProviderFactory.makeProvider(),
                APIProvider: TrustProviderFactory.makeAPIProvider(),
                balanceService: FakeGetBalanceCoordinator(),
                account: .make(),
                config: .make()
            ), transactionsStore: FakeTransactionsStorage()
        )
        
        coordinator.start()
        
        XCTAssertTrue(coordinator.navigationController.viewControllers[0] is WalletViewController)
    }
}
