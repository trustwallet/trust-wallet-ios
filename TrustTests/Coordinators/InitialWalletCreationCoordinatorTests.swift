// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust

class InitialWalletCreationCoordinatorTests: XCTestCase {

    func testImportWallet() {
        let coordinator = InitialWalletCreationCoordinator(
            navigationController: FakeNavigationController(),
            keystore: FakeKeystore(),
            entryPoint: .importWallet
        )

        coordinator.start()

        XCTAssertTrue((coordinator.navigationController.presentedViewController as? NavigationController)?.viewControllers[0] is ImportWalletViewController)
    }
}
