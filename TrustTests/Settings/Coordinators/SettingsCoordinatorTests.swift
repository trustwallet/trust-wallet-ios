// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust

class SettingsCoordinatorTests: XCTestCase {

    func testOnDeleteCleanStorage() {
        let storage = FakeTransactionsStorage()
        let coordinator = SettingsCoordinator(
            navigationController: FakeNavigationController(),
            keystore: FakeEtherKeystore(),
            session: .make(),
            storage: storage,
            walletStorage: FakeWalletStorage(),
            balanceCoordinator: FakeGetBalanceCoordinator(),
            sharedRealm: .make()
        )
        storage.add([.make()])
        storage.updateTransactionSection()
        
        XCTAssertEqual(1, storage.transactionSections.count)
        
        let accountCoordinator = AccountsCoordinator(
            navigationController: FakeNavigationController(),
            keystore: FakeEtherKeystore(),
            session: .make(),
            balanceCoordinator: FakeGetBalanceCoordinator()
        )
        
        coordinator.didDeleteAccount(account: .make(), in: accountCoordinator)
        storage.updateTransactionSection()
        
        XCTAssertEqual(0, storage.transactionSections.count)
    }
}
