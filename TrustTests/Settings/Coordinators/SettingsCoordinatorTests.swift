// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class SettingsCoordinatorTests: XCTestCase {

    func testOnDeleteCleanStorage() {
        let storage = FakeTransactionsStorage()
        let coordinator = SettingsCoordinator(
            navigationController: FakeNavigationController(),
            keystore: FakeEtherKeystore(),
            session: .make(),
            storage: FakeTransactionsStorage(),
            balanceCoordinator: FakeGetBalanceCoordinator()
        )
        storage.add([.make()])
        
        XCTAssertEqual(1, storage.count)
        
        let accountCoordinator = AccountsCoordinator(
            navigationController: FakeNavigationController(),
            keystore: FakeEtherKeystore(),
            session: .make(),
            balanceCoordinator: FakeGetBalanceCoordinator()
        )
        
        coordinator.didDeleteAccount(account: .make(), in: accountCoordinator)
        
        XCTAssertEqual(0, storage.count)
    }
}
