// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust
import TrustKeystore
import KeychainSwift
import BigInt

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
            password: "test",
            newPassword: "test"
        )

        guard case let .success(account) = result else {
            return XCTFail()
        }

        XCTAssertEqual("5e9c27156a612a2d516c74c7a80af107856f8539", account.address.description)
        XCTAssertEqual(1, keystore.accounts.count)
    }

    func testImportDuplicate() {
        let keystore = FakeEtherKeystore()

        let result1 = keystore.importKeystore(
            value: TestKeyStore.keystore,
            password: TestKeyStore.password,
            newPassword: TestKeyStore.newPassword
        )

        let result2 = keystore.importKeystore(
            value: TestKeyStore.keystore,
            password: TestKeyStore.password,
            newPassword: TestKeyStore.newPassword
        )

        guard case let .success(account) = result1 else {
            return XCTFail()
        }

        guard case .failure(KeystoreError.duplicateAccount) = result2 else {
            return XCTFail()
        }

        XCTAssertEqual("5e9c27156a612a2d516c74c7a80af107856f8539", account.address.description)
        XCTAssertEqual(1, keystore.accounts.count)
    }

    func testImportFailInvalidPassword() {
        let keystore = FakeEtherKeystore()

        let result = keystore.importKeystore(
            value: TestKeyStore.keystore,
            password: "invalidPassword",
            newPassword: TestKeyStore.password
        )

        guard case .failure = result else {
            return XCTFail()
        }

        XCTAssertEqual(0, keystore.accounts.count)
    }

    func testImportUsesNewPasswordForEncryption() {
        let keystore = FakeEtherKeystore()
        let password = TestKeyStore.password
        let newPassword = "newPassword"

        let result = keystore.importKeystore(
            value: TestKeyStore.keystore,
            password: password,
            newPassword: newPassword
        )

        guard case let .success(account) = result else {
            return XCTFail()
        }

        let retreivePassword = keystore.getPassword(for: account)

        XCTAssertEqual(newPassword, retreivePassword)
        XCTAssertEqual("5e9c27156a612a2d516c74c7a80af107856f8539", account.address.description)
        XCTAssertEqual(1, keystore.accounts.count)

        let exportResult = keystore.export(account: account, password: newPassword, newPassword: "test2")

        guard case .success = exportResult else {
            return XCTAssertFalse(true)
        }
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
        let passphrase = "MyHardPassword!"
        let result = keystore.convertPrivateKeyToKeystoreFile(privateKey: TestKeyStore.testPrivateKey, passphrase: passphrase)
        
        guard case .success(let dict) = result else {
            return XCTFail()
        }

        let importResult = keystore.importKeystore(
            value: dict.jsonString ?? "",
            password: passphrase,
            newPassword: TestKeyStore.password
        )

        guard case .success = importResult else {
            return XCTFail()
        }

        XCTAssertEqual(1, keystore.accounts.count)
    }
}
