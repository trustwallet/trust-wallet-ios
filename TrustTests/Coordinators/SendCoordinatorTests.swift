// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust
import TrustCore

class SendCoordinatorTests: XCTestCase {
    
    func testRootViewController() {
        let coordinator = SendCoordinator(
            transferType: .ether(destination: .none),
            navigationController: FakeNavigationController(),
            session: .make(),
            keystore: FakeKeystore(),
            storage: FakeTokensDataStore(),
            account: .make()
        )

        XCTAssertTrue(coordinator.rootViewController is SendViewController)
    }

    func testDestanation() {
        let address: EthereumAddress = .make()
        let coordinator = SendCoordinator(
            transferType: .ether(destination: address),
            navigationController: FakeNavigationController(),
            session: .make(),
            keystore: FakeKeystore(),
            storage: FakeTokensDataStore(),
            account: .make()
        )

        XCTAssertEqual(address.description, ((coordinator.rootViewController) as? SendViewController)?.addressRow?.value)
        XCTAssertTrue(coordinator.rootViewController is SendViewController)
    }
}
