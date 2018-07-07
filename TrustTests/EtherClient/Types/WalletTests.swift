// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust
import TrustCore

class WalletTests: XCTestCase {

    func testPrivateKeyAddressDescription() {
        let wallet = Trust.Wallet(type: .privateKey(.make()))

        XCTAssertEqual("wallet-private-key-\(wallet.address.description)", wallet.description)
    }

    func testHDWalletAddressDescription() {
        let wallet = Trust.Wallet(type: .hd(.make()))

        XCTAssertEqual("wallet-hd-wallet-\(wallet.address.description)", wallet.description)
    }

    func testWalletAddressDescription() {
        let wallet = Trust.Wallet(type: .address(.make()))

        XCTAssertEqual("wallet-address-\(wallet.address.description)", wallet.description)
    }
}
