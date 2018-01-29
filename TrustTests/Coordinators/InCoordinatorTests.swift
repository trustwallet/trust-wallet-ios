// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust
import TrustKeystore

class InCoordinatorTests: XCTestCase {
    
    func testShowTabBar() {
        let config: Config = .make()
        let coordinator = InCoordinator(
            navigationController: FakeNavigationController(),
            wallet: .make(),
            keystore: FakeEtherKeystore(),
            config: config
        )

        coordinator.start()

        let tabbarController = coordinator.navigationController.viewControllers[0] as? UITabBarController

        XCTAssertNotNil(tabbarController)

        if config.isDAppsBrowserAvailable {
            XCTAssert((tabbarController?.viewControllers?[0] as? UINavigationController)?.viewControllers[0] is BrowserViewController)
            XCTAssert((tabbarController?.viewControllers?[1] as? UINavigationController)?.viewControllers[0] is TransactionsViewController)
            XCTAssert((tabbarController?.viewControllers?[2] as? UINavigationController)?.viewControllers[0] is TokensViewController)
            XCTAssert((tabbarController?.viewControllers?[3] as? UINavigationController)?.viewControllers[0] is SettingsViewController)
        } else {
            XCTAssert((tabbarController?.viewControllers?[0] as? UINavigationController)?.viewControllers[0] is TransactionsViewController)
            XCTAssert((tabbarController?.viewControllers?[1] as? UINavigationController)?.viewControllers[0] is TokensViewController)
            XCTAssert((tabbarController?.viewControllers?[2] as? UINavigationController)?.viewControllers[0] is SettingsViewController)
        }
    }

    func testChangeRecentlyUsedAccount() {
        let account1: Wallet = .make(type: .watch(Address(string: "0x1000000000000000000000000000000000000000")!))
        let account2: Wallet = .make(type: .watch(Address(string: "0x2000000000000000000000000000000000000000")!))

        let keystore = FakeKeystore(
            wallets: [
                account1,
                account2
            ]
        )
        let coordinator = InCoordinator(
            navigationController: FakeNavigationController(),
            wallet: .make(),
            keystore: keystore,
            config: .make()
        )

        coordinator.showTabBar(for: account1)

        XCTAssertEqual(coordinator.keystore.recentlyUsedWallet, account1)

        coordinator.showTabBar(for: account2)

        XCTAssertEqual(coordinator.keystore.recentlyUsedWallet, account2)
    }

    func testShowSendFlow() {
       let coordinator = InCoordinator(
            navigationController: FakeNavigationController(),
            wallet: .make(),
            keystore: FakeEtherKeystore(),
            config: .make()
        )
        coordinator.showTabBar(for: .make())

        coordinator.showPaymentFlow(for: .send(type: .ether(destination: .none)))

        let controller = (coordinator.navigationController.presentedViewController as? UINavigationController)?.viewControllers[0]

        XCTAssertTrue(coordinator.coordinators.last is PaymentCoordinator)
        XCTAssertTrue(controller is SendViewController)
    }

    func testShowRequstFlow() {
        let coordinator = InCoordinator(
            navigationController: FakeNavigationController(),
            wallet: .make(),
            keystore: FakeEtherKeystore(),
            config: .make()
        )
        coordinator.showTabBar(for: .make())

        coordinator.showPaymentFlow(for: .request)

        let controller = (coordinator.navigationController.presentedViewController as? UINavigationController)?.viewControllers[0]

        XCTAssertTrue(coordinator.coordinators.last is PaymentCoordinator)
        XCTAssertTrue(controller is RequestViewController)
    }
}
