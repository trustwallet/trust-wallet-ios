// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust
import KeychainSwift
import Geth

class EtherKeystoreTests: XCTestCase {
    
    func testInitialization() {
        let keystore = FakeEtherKeystore()

        XCTAssertNotNil(keystore)
        XCTAssertEqual(false, keystore.hasAccounts)
    }

    func testCreateWallet() {
        let keystore = FakeEtherKeystore()
        let password = "test"

        let account = keystore.createAccout(password: password)
        let retrivedPassword = keystore.getPassword(for: account)

        XCTAssertEqual(password, retrivedPassword)
        XCTAssertEqual(1, keystore.accounts.count)
    }

    func testSetAndGetPasswordForAccount() {
        let keystore = FakeEtherKeystore()
        let password = "test"
        let account: Account = .make()

        let setPassword = keystore.setPassword(password, for: account)
        let retrivedPassword = keystore.getPassword(for: account)

        XCTAssertEqual(true, setPassword)
        XCTAssertEqual(retrivedPassword, password)
    }

    func testImport() {
        let keystore = FakeEtherKeystore()

        let result = keystore.importKeystore(
            value: "{\"address\":\"5e9c27156a612a2d516c74c7a80af107856f8539\",\"crypto\":{\"cipher\":\"aes-128-ctr\",\"ciphertext\":\"5eb0c790d1fb27824c78acac9233241b340c329b46aba08c6533b70ab67ea74f\",\"cipherparams\":{\"iv\":\"e5ab559977af075eda00a97c8f0ce506\"},\"kdf\":\"scrypt\",\"kdfparams\":{\"dklen\":32,\"n\":4096,\"p\":6,\"r\":8,\"salt\":\"b43142f34caf2b3b39c16f52344701f800711589f799cdae1827ac2f844f9602\"},\"mac\":\"c6ccaecca7896974dacac91a8116216ec287930bc74bfd7694a94f08bd992095\"},\"id\":\"e3554f73-4d0a-40a0-b721-fc801623d5ba\",\"version\":3}",
            password: "test"
        )

        guard case let .success(account) = result else {
            return XCTFail()
        }

        XCTAssertEqual("0x5E9c27156a612a2D516C74c7a80af107856F8539", account.address.address)
        XCTAssertEqual(1, keystore.accounts.count)
    }

    func testImportFailInvalidPassword() {
        let keystore = FakeEtherKeystore()

        let result = keystore.importKeystore(
            value: "{\"address\":\"5e9c27156a612a2d516c74c7a80af107856f8539\",\"crypto\":{\"cipher\":\"aes-128-ctr\",\"ciphertext\":\"5eb0c790d1fb27824c78acac9233241b340c329b46aba08c6533b70ab67ea74f\",\"cipherparams\":{\"iv\":\"e5ab559977af075eda00a97c8f0ce506\"},\"kdf\":\"scrypt\",\"kdfparams\":{\"dklen\":32,\"n\":4096,\"p\":6,\"r\":8,\"salt\":\"b43142f34caf2b3b39c16f52344701f800711589f799cdae1827ac2f844f9602\"},\"mac\":\"c6ccaecca7896974dacac91a8116216ec287930bc74bfd7694a94f08bd992095\"},\"id\":\"e3554f73-4d0a-40a0-b721-fc801623d5ba\",\"version\":3}",
            password: "invalidPassword"
        )

        guard case .failure = result else {
            return XCTFail()
        }

        XCTAssertEqual(0, keystore.accounts.count)
    }

    func testExport() {
        let keystore = FakeEtherKeystore()
        let password = "test"

        let account = keystore.createAccout(password: password)

        let result = keystore.export(account: account, password: password)

        guard case .success = result else {
            return XCTAssertFalse(true)
        }

        XCTAssertTrue(true)
    }

    func testRecentlyUsedAccount() {
        let keystore = FakeEtherKeystore()
        let password = "test"

        XCTAssertNil(keystore.recentlyUsedAccount)

        let account = keystore.createAccout(password: password)

        keystore.recentlyUsedAccount = account

        XCTAssertEqual(account, keystore.recentlyUsedAccount)

        keystore.recentlyUsedAccount = nil

        XCTAssertNil(keystore.recentlyUsedAccount)
    }

    func testSignTransaction() {
        let keystore = FakeEtherKeystore()
        let account = keystore.createAccout(password: "test")

        let transaction = keystore.signTransaction(
            amount: GethNewBigInt(1),
            account: account,
            address: .make(),
            nonce: 0,
            speed: .regular
        )

        guard case .success = transaction else {
            return XCTAssertFalse(true)
        }

        XCTAssertTrue(true)
    }

    func testDeleteAccount() {
        let keystore = FakeEtherKeystore()
        let password = "test"
        let account = keystore.createAccout(password: password)

        XCTAssertEqual(1, keystore.accounts.count)

        let result = keystore.delete(account: account, password: password)

        guard case .success = result else {
            return XCTFail()
        }

        XCTAssertEqual(0, keystore.accounts.count)
    }

    func testDeleteAccountFail() {
        let keystore = FakeEtherKeystore()
        let password = "test"
        let account = keystore.createAccout(password: password)

        XCTAssertEqual(1, keystore.accounts.count)

        let result = keystore.delete(account: account, password: "invalidPassword")

        guard case .failure = result else {
            return XCTFail()
        }

        XCTAssertEqual(1, keystore.accounts.count)
    }
}

