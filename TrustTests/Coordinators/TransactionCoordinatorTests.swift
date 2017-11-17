// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class TransactionCoordinatorTests: XCTestCase {
    
    func testShowSettings() {
        let coordinator = TransactionCoordinator(
            session: .make(),
            navigationController: FakeNavigationController(),
            storage: FakeTransactionsStorage(),
            keystore: FakeEtherKeystore()
        )

        coordinator.showSettings()

        XCTAssertTrue(coordinator.coordinators.first is SettingsCoordinator)
        XCTAssertTrue((coordinator.navigationController.presentedViewController as? UINavigationController)?.viewControllers[0] is SettingsViewController)
    }

    func testShowSendFlow() {
        let coordinator = TransactionCoordinator(
            session: .make(),
            navigationController: FakeNavigationController(),
            storage: FakeTransactionsStorage(),
            keystore: FakeEtherKeystore()
        )

        coordinator.showPaymentFlow(for: .send(type: .ether(destination: .none)), session: .make())

        let controller = (coordinator.navigationController.presentedViewController as? UINavigationController)?.viewControllers[0]

        XCTAssertTrue(coordinator.coordinators.first is PaymentCoordinator)
        XCTAssertTrue(controller is SendViewController)
    }

    func testShowRequstFlow() {
        let coordinator = TransactionCoordinator(
            session: .make(),
            navigationController: FakeNavigationController(),
            storage: FakeTransactionsStorage(),
            keystore: FakeEtherKeystore()
        )

        coordinator.showPaymentFlow(for: .request, session: .make())

        let controller = (coordinator.navigationController.presentedViewController as? UINavigationController)?.viewControllers[0]

        XCTAssertTrue(coordinator.coordinators.first is PaymentCoordinator)
        XCTAssertTrue(controller is RequestViewController)
    }

    func testShowAccounts() {
        let coordinator = TransactionCoordinator(
            session: .make(),
            navigationController: FakeNavigationController(),
            storage: FakeTransactionsStorage(),
            keystore: FakeEtherKeystore()
        )

        coordinator.showAccounts()

        XCTAssertTrue(coordinator.coordinators.first is AccountsCoordinator)
        XCTAssertTrue((coordinator.navigationController.presentedViewController as? UINavigationController)?.viewControllers[0] is AccountsViewController)
    }
}
