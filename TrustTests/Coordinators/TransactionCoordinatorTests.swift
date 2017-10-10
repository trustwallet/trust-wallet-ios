// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class TransactionCoordinatorTests: XCTestCase {
    
    func testShowTokens() {
        let coordinator = TransactionCoordinator(
            account: .make(),
            rootNavigationController: FakeNavigationController()
        )

        coordinator.showTokens(for: .make())

        XCTAssertTrue(coordinator.navigationController.viewControllers[0] is TokensViewController)
    }

    func testShowAccounts() {
        let coordinator = TransactionCoordinator(
            account: .make(),
            rootNavigationController: FakeNavigationController()
        )

        coordinator.showAccounts()

        XCTAssertTrue((coordinator.navigationController.presentedViewController as? UINavigationController)?.viewControllers[0] is AccountsViewController)
    }

    func testShowSettings() {
        let coordinator = TransactionCoordinator(
            account: .make(),
            rootNavigationController: FakeNavigationController()
        )

        coordinator.showSettings()

        XCTAssertTrue((coordinator.navigationController.presentedViewController as? UINavigationController)?.viewControllers[0] is SettingsViewController)
    }

    func testShowSendFlow() {
        let coordinator = TransactionCoordinator(
            account: .make(),
            rootNavigationController: FakeNavigationController()
        )

        coordinator.showPaymentFlow(for: .send(destination: .none), account: .make())

        let controller = (coordinator.navigationController.presentedViewController as? UINavigationController)?.viewControllers[0]

        XCTAssertTrue(controller is SendAndRequestViewContainer)
        XCTAssertTrue(controller?.childViewControllers[0] is SendViewController)
    }

    func testShowRequstFlow() {
        let coordinator = TransactionCoordinator(
            account: .make(),
            rootNavigationController: FakeNavigationController()
        )

        coordinator.showPaymentFlow(for: .request, account: .make())

        let controller = (coordinator.navigationController.presentedViewController as? UINavigationController)?.viewControllers[0]

        XCTAssertTrue(controller is SendAndRequestViewContainer)
        XCTAssertTrue(controller?.childViewControllers[0] is RequestViewController)
    }
}
