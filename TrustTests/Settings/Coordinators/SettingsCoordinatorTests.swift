// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class SettingsCoordinatorTests: XCTestCase {
    
    func testShowAccounts() {
        let coordinator = SettingsCoordinator(
            navigationController: FakeNavigationController(),
            keystore: FakeEtherKeystore(),
            session: .make(),
            storage: FakeTransactionsStorage()
        )
        
        coordinator.showAccounts()
        
        XCTAssertTrue(coordinator.coordinators.first is AccountsCoordinator)
        XCTAssertTrue((coordinator.navigationController.presentedViewController as? UINavigationController)?.viewControllers[0] is AccountsViewController)
    }
    
    func testOnDeleteCleanStorage() {
        let storage = FakeTransactionsStorage()
        let coordinator = SettingsCoordinator(
            navigationController: FakeNavigationController(),
            keystore: FakeEtherKeystore(),
            session: .make(),
            storage: FakeTransactionsStorage()
        )
        storage.add([.make()])
        
        XCTAssertEqual(1, storage.count)
        
        let accountCoordinator = AccountsCoordinator(
            navigationController: FakeNavigationController(),
            keystore: FakeEtherKeystore()
        )
        
        coordinator.didDeleteAccount(account: .make(), in: accountCoordinator)
        
        XCTAssertEqual(0, storage.count)
    }
}
