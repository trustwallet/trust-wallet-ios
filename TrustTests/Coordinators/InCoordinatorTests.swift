// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust
import TrustCore

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

        XCTAssert((tabbarController?.viewControllers?[0] as? UINavigationController)?.viewControllers[0] is MasterBrowserViewController)
        XCTAssert((tabbarController?.viewControllers?[1] as? UINavigationController)?.viewControllers[0] is WalletViewController)
        XCTAssert((tabbarController?.viewControllers?[2] as? UINavigationController)?.viewControllers[0] is SettingsViewController)
    }

    func testChangeRecentlyUsedAccount() {
        let account1: Trust.WalletInfo = WalletInfo(wallet: .make(type: .address(Address(string: "0x1000000000000000000000000000000000000000")!)))
        let account2: Trust.WalletInfo = WalletInfo(wallet: .make(type: .address(Address(string: "0x2000000000000000000000000000000000000000")!)))

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

        // Needs to inject navigation controller to wallet coordinator
        // let controller = coordinator.tokensCoordinator?.navigationController.viewControllers.last
        // XCTAssertTrue(controller is SendViewController)
    }

    func testShowRequstFlow() {
        let coordinator = InCoordinator(
            navigationController: FakeNavigationController(),
            wallet: .make(),
            keystore: FakeEtherKeystore(),
            config: .make()
        )
        coordinator.showTabBar(for: .make())

        coordinator.showPaymentFlow(for: .request(token: .make()))

        // Needs to inject navigation controller to wallet coordinator
        // let controller = coordinator.tokensCoordinator?.navigationController.viewControllers.last
        // XCTAssertTrue(controller is RequestViewController)
    }

    func testShowTabDefault() {
        let coordinator = InCoordinator(
            navigationController: FakeNavigationController(),
            wallet: .make(),
            keystore: FakeEtherKeystore(),
            config: .make()
        )
        coordinator.showTabBar(for: .make())

        coordinator.showTab(.wallet(.none))

        let viewController = (coordinator.tabBarController?.selectedViewController as? UINavigationController)?.viewControllers[0]

        XCTAssert(viewController is WalletViewController)
    }
}
