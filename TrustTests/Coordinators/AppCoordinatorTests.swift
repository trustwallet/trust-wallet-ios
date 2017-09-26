// Copyright SIX DAY LLC. All rights reserved.

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
    
    func testShowAccounts() {
        let coordinator = AppCoordinator(
            window: UIWindow(),
            keystore: FakeKeystore(
                accounts: [.make()]
            ),
            rootNavigationController: FakeNavigationController()
        )
        coordinator.start()
        
        coordinator.showAccounts()
        
        XCTAssertTrue((coordinator.rootNavigationController.presentedViewController as? UINavigationController)?.viewControllers[0] is AccountsViewController)
    }
    
    func testShowSettings() {
        let coordinator = AppCoordinator(
            window: UIWindow(),
            keystore: FakeKeystore(
                accounts: [.make()]
            ),
            rootNavigationController: FakeNavigationController()
        )
        coordinator.start()
        
        coordinator.showSettings()
        
        XCTAssertTrue((coordinator.rootNavigationController.presentedViewController as? UINavigationController)?.viewControllers[0] is SettingsViewController)
    }
    
    func testStartWalletCoordinator() {
        let coordinator = AppCoordinator(
            window: UIWindow(),
            keystore: FakeKeystore(
                accounts: [.make()]
            ),
            rootNavigationController: FakeNavigationController()
        )
        coordinator.start()
        
        coordinator.showCreateWallet()
        
        XCTAssertTrue((coordinator.rootNavigationController.presentedViewController as? UINavigationController)?.viewControllers[0] is CreateWalletViewController)
    }
    
    func testShowTransactions() {
        let coordinator = AppCoordinator(
            window: UIWindow(),
            keystore: FakeKeystore(
                accounts: [.make()]
            ),
            rootNavigationController: FakeNavigationController()
        )
        coordinator.start()
        
        coordinator.showTransactions(for: .make())
        
        XCTAssertTrue(coordinator.rootNavigationController.viewControllers[0] is TransactionsViewController)
    }

    func testShowTokens() {
        let coordinator = AppCoordinator(
            window: UIWindow(),
            keystore: FakeKeystore(
                accounts: [.make()]
            ),
            rootNavigationController: FakeNavigationController()
        )
        coordinator.start()

        coordinator.showTokens(for: .make())

        XCTAssertTrue(coordinator.rootNavigationController.viewControllers[1] is TokensViewController)
    }
}
