// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust
import TrustCore

class WalletTests: XCTestCase {

    func testPrivateKeyAddressDescription() {
        let wallet = Trust.Wallet(type: .privateKey(.make()))

        XCTAssertEqual("wallet-private-key-\(address.description)", wallet.description)
    }

    func testHDWalletAddressDescription() {
        let wallet = Trust.Wallet(type: .hd(.make()))

        XCTAssertEqual("wallet-hd-wallet-\(address.description)", wallet.description)
    }

    func testWalletAddressDescription() {
        let wallet = Trust.Wallet(type: .address(.make()))

        XCTAssertEqual("wallet-address-\(address.description)", wallet.description)
    }
}
