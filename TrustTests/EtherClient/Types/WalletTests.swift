// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust
import TrustCore
import TrustKeystore

class WalletTests: XCTestCase {

    func testPrivateKeyAddressDescription() {
        let wallet: Wallet = .make()
        let walletType = WalletType.privateKey(wallet)

        XCTAssertEqual("wallet-private-key-\(wallet.identifier)", walletType.description)
    }

    func testHDWalletAddressDescription() {
        let wallet: Wallet = .make()
        let walletType = WalletType.hd(wallet)

        XCTAssertEqual("wallet-hd-wallet-\(wallet.identifier)", walletType.description)
    }

    func testWalletAddressDescription() {
        let coin: Coin = .ethereum
        let address: EthereumAddress = .make()
        let walletType = WalletType.address(coin, address)

        XCTAssertEqual("wallet-address-\(coin.rawValue)-\(address.description)", walletType.description)
    }
}

