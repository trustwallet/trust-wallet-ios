// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust
import TrustKeystore

class PaymentCoordinatorTests: XCTestCase {

    func testSendFlow() {
        let address: Address = .make()
        let coordinator = PaymentCoordinator(
            navigationController: FakeNavigationController(),
            flow: .send(type: .ether(destination: address)),
            session: .make(),
            keystore: FakeKeystore()
        )
        coordinator.start()

        XCTAssertEqual(1, coordinator.coordinators.count)
        XCTAssertTrue(coordinator.coordinators.first is SendCoordinator)
    }

    func testRequestFlow() {
        let coordinator = PaymentCoordinator(
            navigationController: FakeNavigationController(),
            flow: .request,
            session: .make(),
            keystore: FakeKeystore()
        )

        coordinator.start()

        XCTAssertEqual(1, coordinator.coordinators.count)
        XCTAssertTrue(coordinator.coordinators.first is RequestCoordinator)
    }
}
