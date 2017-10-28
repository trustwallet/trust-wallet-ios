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

    func testEmptyPassword() {
        let keystore = FakeEtherKeystore()

        let password = keystore.getPassword(for: .make())

        XCTAssertNil(password)
    }

    func testImport() {
        let keystore = FakeEtherKeystore()

        let result = keystore.importKeystore(
            value: TestKeyStore.keystore,
            password: "test"
        )

        guard case let .success(account) = result else {
            return XCTFail()
        }

        XCTAssertEqual("0x5e9c27156a612a2d516c74c7a80af107856f8539", account.address.address)
        XCTAssertEqual(1, keystore.accounts.count)
    }

    func testImportDuplicate() {
        let keystore = FakeEtherKeystore()

        let result1 = keystore.importKeystore(
            value: TestKeyStore.keystore,
            password: TestKeyStore.password
        )

        let result2 = keystore.importKeystore(
            value: TestKeyStore.keystore,
            password: TestKeyStore.password
        )

        guard case let .success(account) = result1 else {
            return XCTFail()
        }

        guard case .failure(KeyStoreError.duplicateAccount) = result2 else {
            return XCTFail()
        }

        XCTAssertEqual("0x5e9c27156a612a2d516c74c7a80af107856f8539", account.address.address)
        XCTAssertEqual(1, keystore.accounts.count)
    }

    func testImportFailInvalidPassword() {
        let keystore = FakeEtherKeystore()

        let result = keystore.importKeystore(
            value: TestKeyStore.keystore,
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

        let result = keystore.export(account: account, password: password, newPassword: password)

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

        let signTransaction = SignTransaction(
            amount: GethNewBigInt(1),
            account: account,
            address: .make(address: "0x123f681646d4a755815f9cb19e1acc8565a0c2ac"),
            nonce: 0,
            speed: .regular,
            data: Data(),
            chainID: GethNewBigInt(1)
        )

        let signedTransaction = keystore.signTransaction(signTransaction)

        guard case .success = signedTransaction else {
            return XCTAssertFalse(true)
        }

        XCTAssertTrue(true)
    }

    func testDeleteAccount() {
        let keystore = FakeEtherKeystore()
        let password = "test"
        let account = keystore.createAccout(password: password)

        XCTAssertEqual(1, keystore.accounts.count)

        let result = keystore.delete(account: account)

        guard case .success = result else {
            return XCTFail()
        }

        XCTAssertEqual(0, keystore.accounts.count)
    }

    func testConvertPrivateKeyToKeyStore() {
        let keystore = FakeEtherKeystore()
        let privateKey = "9cdb5cab19aec3bd0fcd614c5f185e7a1d97634d4225730eba22497dc89a716c"
        let passphrase = "MyHardPassword!"
        let result = keystore.convertPrivateKeyToKeystoreFile(privateKey: privateKey, passphrase: passphrase)
        
        guard case .success(let dict) = result else {
            return XCTFail()
        }

        let importResult = keystore.importKeystore(
            value: dict.jsonString ?? "",
            password: passphrase
        )

        guard case .success = importResult else {
            return XCTFail()
        }

        XCTAssertEqual(1, keystore.accounts.count)
    }
}

