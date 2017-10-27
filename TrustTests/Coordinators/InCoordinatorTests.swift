// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class InCoordinatorTests: XCTestCase {
    
    func testShowTransactions() {
        let coordinator = InCoordinator(
            navigationController: FakeNavigationController(),
            account: .make(),
            keystore: FakeEtherKeystore()
        )

        coordinator.start()

        XCTAssertTrue(coordinator.navigationController.viewControllers[0] is TransactionsViewController)
    }

    func testChangeRecentlyUsedAccount() {
        let account1: Account = .make(address: .make(address: "0x1"))
        let account2: Account = .make(address: .make(address: "0x2"))

        let keystore = FakeKeystore(
            accounts: [
                account1,
                account2
            ]
        )
        let coordinator = InCoordinator(
            navigationController: FakeNavigationController(),
            account: .make(),
            keystore: keystore
        )

        coordinator.showTransactions(for: account1)

        XCTAssertEqual(coordinator.keystore.recentlyUsedAccount, account1)

        coordinator.showTransactions(for: account2)

        XCTAssertEqual(coordinator.keystore.recentlyUsedAccount, account2)
    }
}
