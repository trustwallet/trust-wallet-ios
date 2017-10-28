// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class PaymentCoordinatorTests: XCTestCase {
    
    func testSendFlow() {
        let coordinator = PaymentCoordinator(
            navigationController: FakeNavigationController(),
            flow: .send(type: .ether(destination: .none)),
            session: .make()
        )

        XCTAssertTrue(coordinator.navigationController.viewControllers[0] is SendViewController)
    }

    func testSendFlowDestination() {
        let address: Address = .make()
        let coordinator = PaymentCoordinator(
            navigationController: FakeNavigationController(),
            flow: .send(type: .ether(destination: address)),
            session: .make()
        )

        XCTAssertEqual(address.address, coordinator.sendViewController.addressRow?.value)
        XCTAssertTrue(coordinator.navigationController.viewControllers[0] is SendViewController)
    }

    func testRequestFlow() {
        let coordinator = PaymentCoordinator(
            navigationController: FakeNavigationController(),
            flow: .request,
            session: .make()
        )

        XCTAssertTrue(coordinator.navigationController.viewControllers[0] is RequestViewController)
    }
}
