// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust
import TrustCore
import TrustKeystore
import KeychainSwift
import BigInt

class EtherKeystoreTests: XCTestCase {

    func testInitialization() {
        let keystore = FakeEtherKeystore()

        XCTAssertNotNil(keystore)
        XCTAssertEqual(false, keystore.hasWallets)
    }

    func testCreateWallet() {
        let keystore = FakeEtherKeystore()
        let password = "test"

        let account = keystore.createAccout(password: password)
        let retrivedPassword = keystore.getPassword(for: account.accounts[0])

        XCTAssertEqual(password, retrivedPassword)
        XCTAssertEqual(1, keystore.wallets.count)
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
            password: TestKeyStore.password,
            newPassword: TestKeyStore.password
        )

        guard case let .success(account) = result else {
            return XCTFail()
        }

        XCTAssertEqual("0x5E9c27156a612a2D516C74c7a80af107856F8539", account.address.description)
        XCTAssertEqual(1, keystore.wallets.count)
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

        guard case let .success(account1) = result1, case let .success(account2) = result2 else {
            return XCTFail()
        }

        XCTAssertEqual("0x5E9c27156a612a2D516C74c7a80af107856F8539", account1.address.description)
        XCTAssertEqual("0x5E9c27156a612a2D516C74c7a80af107856F8539", account2.address.description)
        XCTAssertEqual(2, keystore.wallets.count)
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

        XCTAssertEqual(0, keystore.wallets.count)
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

        let retreivePassword = keystore.getPassword(for: account.account!)

        XCTAssertEqual(newPassword, retreivePassword)
        XCTAssertEqual("0x5E9c27156a612a2D516C74c7a80af107856F8539", account.address.description)
        XCTAssertEqual(1, keystore.wallets.count)

        let exportResult = keystore.export(account: account.account!, password: newPassword, newPassword: "test2")

        guard case .success = exportResult else {
            return XCTAssertFalse(true)
        }
    }

    func testExport() {
        let keystore = FakeEtherKeystore()
        let password = "test"

        let account = keystore.createAccout(password: password)

        let result = keystore.export(account: account.accounts[0], password: password, newPassword: password)

        guard case .success = result else {
            return XCTAssertFalse(true)
        }

        XCTAssertTrue(true)
    }

    func testRecentlyUsedAccount() {
        let keystore = FakeEtherKeystore()
        let password = "test"

        XCTAssertNil(keystore.recentlyUsedWallet)

        let account = WalletInfo(wallet: WalletStruct(type: .hd(keystore.createAccout(password: password))))

        keystore.recentlyUsedWallet = account

        XCTAssertEqual(account, keystore.recentlyUsedWallet)

        keystore.recentlyUsedWallet = nil

        XCTAssertNil(keystore.recentlyUsedWallet)
    }

    func testDeleteAccount() {
        let keystore = FakeEtherKeystore()
        let password = "test"
        let wallet = WalletStruct(type: .privateKey(keystore.createAccout(password: password)))

        XCTAssertEqual(1, keystore.wallets.count)

        let result = keystore.delete(wallet: wallet)

        guard case .success = result else {
            return XCTFail()
        }

        XCTAssertEqual(0, keystore.wallets.count)
    }

    func testSignPersonalMessage() {
        let keystore = FakeEtherKeystore()

        let result = keystore.importKeystore(
            value: TestKeyStore.keystore,
            password: TestKeyStore.password,
            newPassword: TestKeyStore.password
        )

        guard case let .success(account) = result else {
            return XCTFail()
        }

        let signResult = keystore.signPersonalMessage("Some data".data(using: .utf8)!, for: account.account!)

        guard case let .success(data) = signResult else {
            return XCTFail()
        }

        let expected = Data(hexString: "0x58156c371347613642e94b66abc4ced8e36011fb3233f5372371aa5ad321671b1a10c0b88f47ce543fd4c455761f5fbf8f61d050f57dcba986640011da794a901b")

        XCTAssertEqual(expected, data)
    }

    func testSignUTF8PersonalMessage() {
        let keystore = FakeEtherKeystore()

        let result = keystore.importKeystore(
            value: TestKeyStore.keystore,
            password: TestKeyStore.password,
            newPassword: TestKeyStore.password
        )

        guard case let .success(account) = result else {
            return XCTFail()
        }

        let signResult = keystore.signPersonalMessage("♥".data(using: .utf8)!, for: account.account!)

        guard case let .success(data) = signResult else {
            return XCTFail()
        }

        let expected = Data(hexString: "0xf8441cee41f499f1e6730baef72db22e52c00225a1fbce948af38f890ccd720117d612032d6255b1e62d47e9714e462aafd0c5660aa9c1ec3e17ba85f8fc7d851b")

        XCTAssertEqual(expected, data)
    }

    func testSignMessage() {
        let keystore = FakeEtherKeystore()

        let result = keystore.importKeystore(
            value: TestKeyStore.keystore,
            password: TestKeyStore.password,
            newPassword: TestKeyStore.password
        )

        guard case let .success(account) = result else {
            return XCTFail()
        }

        let signResult = keystore.signPersonalMessage("0x3f44c2dfea365f01c1ada3b7600db9e2999dfea9fe6c6017441eafcfbc06a543".data(using: .utf8)!, for: account.account!)

        guard case let .success(data) = signResult else {
            return XCTFail()
        }

        let expected = Data(hexString: "0x315424feb1555f56ab3ac3e0fdbda6aa011865bff874bdca74a9281637377e5c5633339b478933a175f4e5a0dfb3eca882b8a8b6e4642065ef89f87cce65d0e01c")

        XCTAssertEqual(expected, data)
    }

    func testSignTypedMessage() {
        let keystore = FakeEtherKeystore()

        let result = keystore.importKeystore(
            value: TestKeyStore.keystore,
            password: TestKeyStore.password,
            newPassword: TestKeyStore.password
        )

        guard case let .success(account) = result else {
            return XCTFail()
        }

        let typedData = EthTypedData(type: "string", name: "Message", value: .string(value: "Hi, Alice!"))
        let typedData2 = EthTypedData(type: "uint32", name: "A number", value: .uint(value: 1337))

        let signResult = keystore.signTypedMessage([typedData, typedData2], for: account.account!)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }
 
        let expected = Data(hexString: "0x87b558a712b00ce7b22b43b0b7c392d52c4779767e57eed87ac1050592ff0c0c24f7f71c01391e2938e7d2e24a415f7624244cbf468803bf0539be037316efde1c")
        XCTAssertEqual(expected, data)
    }

    func testAddWatchAddress() {
        let keystore = FakeEtherKeystore()
        let address: EthereumAddress = .make()

        keystore.importWallet(type: ImportType.address(address: address)) {_  in }

        XCTAssertEqual(1, keystore.wallets.count)
        XCTAssertEqual(address.data, keystore.wallets[0].address.data)
    }

    func testDeleteWatchAddress() {
        let keystore = FakeEtherKeystore()
        let address: EthereumAddress = .make()

        // TODO. Move this into sync calls
        keystore.importWallet(type: ImportType.address(address: address)) { result  in
            switch result {
            case .success(let wallet):
                XCTAssertEqual(1, keystore.wallets.count)
                XCTAssertEqual(address.data, keystore.wallets[0].address.data)

                let _ = keystore.delete(wallet: wallet)

                XCTAssertEqual(0, keystore.wallets.count)
            case .failure:
                XCTFail()
            }
        }

        XCTAssertEqual(0, keystore.wallets.count)
    }

    func testDeleteHDWallet() {
        let keystore = FakeEtherKeystore()

        // TODO. Move this into sync calls
        keystore.importWallet(type: ImportType.mnemonic(words: ["often", "tobacco", "bread", "scare", "imitate", "song", "kind", "common", "bar", "forest", "yard", "wisdom"], password: "test123")) { result  in
            switch result {
            case .success(let wallet):
                XCTAssertEqual(1, keystore.wallets.count)

                let _ = keystore.delete(wallet: wallet)

                XCTAssertEqual(0, keystore.wallets.count)
            case .failure:
                XCTFail()
            }
        }

        XCTAssertEqual(0, keystore.wallets.count)
    }

// TODO: Address
//    func testKeychainKeyPrivateKey() {
//        let keystore = FakeEtherKeystore()
//        let address = EthereumAddress(string: "0x5e9c27156a612a2d516c74c7a80af107856f8539")!
//        let key = keystore.keychainKey(for: .make(address: address))
//
//        XCTAssertEqual(key, address.description.lowercased())
//    }

// TODO: Address
//    func testKeychainKeyHDWallet() {
//        let keystore = FakeEtherKeystore()
//        let address = EthereumAddress(string: "0x5e9c27156a612a2d516c74c7a80af107856f8539")!
//        let key = keystore.keychainKey(for: .make(address: address))
//
//        XCTAssertEqual(key, "hd-wallet-" + address.description)
//    }
}
