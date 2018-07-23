// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust
import TrustCore

class WalletTests: XCTestCase {

    func testPrivateKeyAddressDescription() {
        let wallet = WalletType.privateKey(.make())

        XCTAssertEqual("wallet-private-key-\(wallet.description)", wallet.description)
    }

    func testHDWalletAddressDescription() {
        let wallet = WalletType.hd(.make())

        XCTAssertEqual("wallet-hd-wallet-\(wallet.description)", wallet.description)
    }

    func testWalletAddressDescription() {
        let wallet = WalletType.address(.ethereum, .make())

        XCTAssertEqual("wallet-address-\(wallet.description)", wallet.description)
    }
}
