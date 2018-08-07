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
        let retrivedPassword = keystore.getPassword(for: account)

        XCTAssertEqual(5, account.accounts.count)
        XCTAssertEqual(password, retrivedPassword)
        XCTAssertEqual(1, keystore.wallets.count)
    }

    func testTwoWallets() {
        let keystore = FakeEtherKeystore()
        let password = "test"

        let _ = keystore.createAccout(password: password)
        let _ = keystore.createAccout(password: password)

        XCTAssertEqual(2, keystore.wallets.count)
    }

    func testSetAndGetPasswordForAccount() {
        let keystore = FakeEtherKeystore()
        let password = "test"
        let account: Wallet = .make()

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
            newPassword: TestKeyStore.password,
            coin: .ethereum
        )

        guard case let .success(account) = result else {
            return XCTFail()
        }

        XCTAssertEqual("0x5E9c27156a612a2D516C74c7a80af107856F8539", account.accounts[0].address.description)
        XCTAssertEqual(1, keystore.wallets.count)
    }

    func testImportDuplicate() {
        let keystore = FakeEtherKeystore()

        let result1 = keystore.importKeystore(
            value: TestKeyStore.keystore,
            password: TestKeyStore.password,
            newPassword: TestKeyStore.newPassword,
            coin: .ethereum
        )

        let result2 = keystore.importKeystore(
            value: TestKeyStore.keystore,
            password: TestKeyStore.password,
            newPassword: TestKeyStore.newPassword,
            coin: .ethereum
        )

        guard case let .success(account1) = result1, case let .success(account2) = result2 else {
            return XCTFail()
        }

        XCTAssertEqual("0x5E9c27156a612a2D516C74c7a80af107856F8539", account1.accounts[0].address.description)
        XCTAssertEqual("0x5E9c27156a612a2D516C74c7a80af107856F8539", account2.accounts[0].address.description)
        XCTAssertEqual(2, keystore.wallets.count)
    }

    func testImportMnemonic() {
        let keystore = FakeEtherKeystore()

        // TODO. Move this into sync calls
        let coin = Coin.ethereum
        keystore.importWallet(type: ImportType.mnemonic(words: ["often", "tobacco", "bread", "scare", "imitate", "song", "kind", "common", "bar", "forest", "yard", "wisdom"], password: "", derivationPath: coin.derivationPath(at: 0)), coin: .ethereum) { result  in
            switch result {
            case .success(let wallet):
                XCTAssertEqual(1, keystore.wallets.count)
                XCTAssertEqual("0x33F44330cc4253cCd4ce4224186DB9baCe2190ea", wallet.accounts[0].address.description)
            case .failure:
                XCTFail()
            }
        }
    }

    func testImportMnemonicWithPassword() {
        let keystore = FakeEtherKeystore()

        // TODO. Move this into sync calls
        let coin = Coin.ethereum
        keystore.importWallet(type: ImportType.mnemonic(words: ["often", "tobacco", "bread", "scare", "imitate", "song", "kind", "common", "bar", "forest", "yard", "wisdom"], password: "test123", derivationPath: coin.derivationPath(at: 0)), coin: .ethereum) { result  in
            switch result {
            case .success(let wallet):
                XCTAssertEqual(1, keystore.wallets.count)
                XCTAssertEqual("0x5f9763AF89b1De8d44F3739d55C00dD6a21C2Cb6", wallet.accounts[0].address.description)
            case .failure:
                XCTFail()
            }
        }
    }

    func testImportFailInvalidPassword() {
        let keystore = FakeEtherKeystore()

        let result = keystore.importKeystore(
            value: TestKeyStore.keystore,
            password: "invalidPassword",
            newPassword: TestKeyStore.password,
            coin: .ethereum
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
            newPassword: newPassword,
            coin: .ethereum
        )

        guard case let .success(account) = result else {
            return XCTFail()
        }

        let retreivePassword = keystore.getPassword(for: account)

        XCTAssertEqual(newPassword, retreivePassword)
        XCTAssertEqual("0x5E9c27156a612a2D516C74c7a80af107856F8539", account.accounts[0].address.description)
        XCTAssertEqual(1, keystore.wallets.count)

        let exportResult = keystore.export(account: account.accounts[0], password: newPassword, newPassword: "test2")

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

        let wallet = keystore.createAccout(password: password)
        let walletInfo = WalletInfo(type: WalletType.hd(wallet))

        keystore.recentlyUsedWallet = walletInfo

        XCTAssertEqual(walletInfo, keystore.recentlyUsedWallet)

        keystore.recentlyUsedWallet = nil

        XCTAssertNil(keystore.recentlyUsedWallet)
    }

    func testDeleteAccount() {
        let keystore = FakeEtherKeystore()
        let password = "test"
        let wallet = keystore.createAccout(password: password)

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
            newPassword: TestKeyStore.password,
            coin: .ethereum
        )

        guard case let .success(account) = result else {
            return XCTFail()
        }

        let signResult = keystore.signPersonalMessage("Some data".data(using: .utf8)!, for: account.accounts[0])

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
            newPassword: TestKeyStore.password,
            coin: .ethereum
        )

        guard case let .success(account) = result else {
            return XCTFail()
        }

        let signResult = keystore.signPersonalMessage("♥".data(using: .utf8)!, for: account.accounts[0])

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
            newPassword: TestKeyStore.password,
            coin: .ethereum
        )

        guard case let .success(account) = result else {
            return XCTFail()
        }

        let signResult = keystore.signPersonalMessage("0x3f44c2dfea365f01c1ada3b7600db9e2999dfea9fe6c6017441eafcfbc06a543".data(using: .utf8)!, for: account.accounts[0])

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
            newPassword: TestKeyStore.password,
            coin: .ethereum
        )

        guard case let .success(account) = result else {
            return XCTFail()
        }

        let typedData = EthTypedData(type: "string", name: "Message", value: .string(value: "Hi, Alice!"))
        let typedData2 = EthTypedData(type: "uint32", name: "A number", value: .uint(value: 1337))

        let signResult = keystore.signTypedMessage([typedData, typedData2], for: account.accounts[0])
        guard case let .success(data) = signResult else {
            return XCTFail()
        }

        let expected = Data(hexString: "0x87b558a712b00ce7b22b43b0b7c392d52c4779767e57eed87ac1050592ff0c0c24f7f71c01391e2938e7d2e24a415f7624244cbf468803bf0539be037316efde1c")
        XCTAssertEqual(expected, data)
    }

    func testAddWatchAddress() {
        let keystore = FakeEtherKeystore()
        let address: EthereumAddress = .make()

        keystore.importWallet(type: ImportType.address(address: address), coin: .ethereum) {_  in }

        XCTAssertEqual(1, keystore.wallets.count)
        XCTAssertEqual(address.data, keystore.wallets[0].address.data)
    }

    func testDeleteWatchAddress() {
        let keystore = FakeEtherKeystore()
        let address: EthereumAddress = .make()

        // TODO. Move this into sync calls
        keystore.importWallet(type: ImportType.address(address: address), coin: .ethereum) { result  in
            switch result {
            case .success(let wallet):
                XCTAssertEqual(1, keystore.wallets.count)
                XCTAssertEqual(address.data, keystore.wallets[0].address.data)

                let _ = keystore.delete(wallet: wallet, completion: { _ in })

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
        let coin = Coin.ethereum
        keystore.importWallet(type: ImportType.mnemonic(words: ["often", "tobacco", "bread", "scare", "imitate", "song", "kind", "common", "bar", "forest", "yard", "wisdom"], password: "test123", derivationPath: coin.derivationPath(at: 0)), coin: .ethereum) { result  in
            switch result {
            case .success(let wallet):
                XCTAssertEqual(1, keystore.wallets.count)

                let _ = keystore.delete(wallet: wallet.currentWallet!)

                XCTAssertEqual(0, keystore.wallets.count)
            case .failure:
                XCTFail()
            }
        }

        XCTAssertEqual(0, keystore.wallets.count)
    }

    func testKeychainKeyPrivateKey() {
        let keystore = FakeEtherKeystore()
        let wallet: Wallet = .make()
        let key = keystore.keychainKey(for: wallet)

        XCTAssertEqual(key, wallet.identifier)
    }
}
