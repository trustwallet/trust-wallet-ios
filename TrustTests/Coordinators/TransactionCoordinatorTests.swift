// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class TransactionCoordinatorTests: XCTestCase {

    func testShowSendFlow() {
        let coordinator = TransactionCoordinator(
            session: .make(),
            navigationController: FakeNavigationController(),
            storage: FakeTransactionsStorage(),
            keystore: FakeEtherKeystore()
        )

        coordinator.showPaymentFlow(for: .send(type: .ether(destination: .none)))

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

        coordinator.showPaymentFlow(for: .request)

        let controller = (coordinator.navigationController.presentedViewController as? UINavigationController)?.viewControllers[0]

        XCTAssertTrue(coordinator.coordinators.first is PaymentCoordinator)
        XCTAssertTrue(controller is RequestViewController)
    }
}
