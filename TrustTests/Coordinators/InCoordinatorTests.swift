// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class InCoordinatorTests: XCTestCase {
    
    func testShowTabBar() {
        let coordinator = InCoordinator(
            navigationController: FakeNavigationController(),
            account: .make(),
            keystore: FakeEtherKeystore(),
            config: .make()
        )

        coordinator.start()

        let tabbarController = coordinator.navigationController.viewControllers[0] as? UITabBarController

        XCTAssertNotNil(tabbarController)

        XCTAssert((tabbarController?.viewControllers?[0] as? UINavigationController)?.viewControllers[0] is TransactionsViewController)
        XCTAssert((tabbarController?.viewControllers?[1] as? UINavigationController)?.viewControllers[0] is TokensViewController)
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
            keystore: keystore,
            config: .make()
        )

        coordinator.showTabBar(for: account1)

        XCTAssertEqual(coordinator.keystore.recentlyUsedAccount, account1)

        coordinator.showTabBar(for: account2)

        XCTAssertEqual(coordinator.keystore.recentlyUsedAccount, account2)
    }
}
