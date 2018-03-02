// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class TokensCoordinatorTests: XCTestCase {
    
    func testRootViewController() {
        let coordinator = TokensCoordinator(
            navigationController: FakeNavigationController(),
            session: .make(),
            keystore: FakeKeystore(),
            tokensStorage: FakeTokensDataStore(),
            network: FakeTokensNetwork(provider: TrustProviderFactory.makeProvider(), balanceService: FakeGetBalanceCoordinator(), account: .make(), config: .make())
        )
        
        coordinator.start()
        
        XCTAssertTrue(coordinator.navigationController.viewControllers[0] is TokensViewController)
    }
}
