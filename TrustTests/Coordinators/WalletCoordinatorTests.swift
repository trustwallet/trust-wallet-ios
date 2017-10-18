// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class WalletCoordinatorTests: XCTestCase {
    
    func testCreateWallet() {
        let coordinator = WalletCoordinator(
            presenterViewController: FakeNavigationController()
        )

        coordinator.start(.createWallet)

        XCTAssertTrue(coordinator.navigationViewController.viewControllers[0] is WelcomeViewController)
    }

    func testImportWallet() {
        let coordinator = WalletCoordinator(
            presenterViewController: FakeNavigationController()
        )

        coordinator.start(.importWallet)

        XCTAssertTrue(coordinator.navigationViewController.viewControllers[0] is ImportWalletViewController)
    }

    func testCreateInstantWallet() {
        let delegate = FakeWalletCoordinatorDelegate()
        let coordinator = WalletCoordinator(
            presenterViewController: FakeNavigationController(),
            keystore: FakeEtherKeystore()
        )
        coordinator.delegate = delegate

        coordinator.start(.createInstantWallet)

        XCTAssertNotNil(delegate.didFinishAccount)
    }

    func testPresentCreateWallet() {
        let coordinator = WalletCoordinator(
            presenterViewController: FakeNavigationController()
        )

        coordinator.presentCreateWallet()

        XCTAssertTrue(coordinator.navigationViewController.viewControllers[0] is WelcomeViewController)
    }

    func testPresentImportWallet() {
        let coordinator = WalletCoordinator(
            presenterViewController: FakeNavigationController()
        )

        coordinator.presentImportWallet()

        XCTAssertTrue(coordinator.navigationViewController.viewControllers[0] is ImportWalletViewController)
    }

    func testPushImportWallet() {
        let coordinator = WalletCoordinator(
            presenterViewController: FakeNavigationController(),
            navigationViewController: FakeNavigationController()
        )

        coordinator.start(.createWallet)

        coordinator.pushImportWallet()

        XCTAssertTrue(coordinator.navigationViewController.viewControllers[1] is ImportWalletViewController)
    }
}

class FakeWalletCoordinatorDelegate: WalletCoordinatorDelegate {

    var didFail: Error? = .none
    var didFinishAccount: Account? = .none
    var didCancel: Bool = false

    func didCancel(in coordinator: WalletCoordinator) {
        didCancel = true
    }

    func didFinish(with account: Account, in coordinator: WalletCoordinator) {
        didFinishAccount = account
    }

    func didFail(with error: Error, in coordinator: WalletCoordinator) {
        didFail = error
    }
}
