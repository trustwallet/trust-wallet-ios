// Copyright SIX DAY LLC, Inc. All rights reserved.

import XCTest
@testable import Trust

class AppCoordinatorTests: XCTestCase {
    
    func testStart() {
        let coordinator = AppCoordinator(
            window: UIWindow(),
            keystore: FakeKeystore()
        )
        
        coordinator.start()
        
        XCTAssertTrue(coordinator.rootNavigationController.viewControllers[0] is WelcomeViewController)
    }
    
    func testStartWithAccounts() {
        let coordinator = AppCoordinator(
            window: UIWindow(),
            keystore: FakeKeystore(
                accounts: [.make()]
            )
        )
        
        coordinator.start()
        
        XCTAssertTrue(coordinator.rootNavigationController.viewControllers[0] is TransactionsViewController)
    }
    
    func testReset() {
        let coordinator = AppCoordinator(
            window: UIWindow(),
            keystore: FakeKeystore(
                accounts: [.make()]
            )
        )
        coordinator.start()
        
        coordinator.reset()
        
        XCTAssertTrue(coordinator.rootNavigationController.viewControllers[0] is WelcomeViewController)
    }
}
