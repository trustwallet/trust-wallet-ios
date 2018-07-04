// Copyright SIX DAY LLC. All rights reserved.

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

        guard case let .success(account) = result1 else {
            return XCTFail()
        }

        guard case .failure(KeystoreError.duplicateAccount) = result2 else {
            return XCTFail()
        }

        XCTAssertEqual("0x5E9c27156a612a2D516C74c7a80af107856F8539", account.address.description)
        XCTAssertEqual(1, keystore.wallets.count)
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

        let retreivePassword = keystore.getPassword(for: account)

        XCTAssertEqual(newPassword, retreivePassword)
        XCTAssertEqual("0x5E9c27156a612a2D516C74c7a80af107856F8539", account.address.description)
        XCTAssertEqual(1, keystore.wallets.count)

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

        XCTAssertNil(keystore.recentlyUsedWallet)

        let account = WalletInfo(wallet: Wallet(type: .hd(keystore.createAccout(password: password))))

        keystore.recentlyUsedWallet = account

        XCTAssertEqual(account, keystore.recentlyUsedWallet)

        keystore.recentlyUsedWallet = nil

        XCTAssertNil(keystore.recentlyUsedWallet)
    }

    func testDeleteAccount() {
        let keystore = FakeEtherKeystore()
        let password = "test"
        let wallet = Wallet(type: .privateKey(keystore.createAccout(password: password)))

        XCTAssertEqual(1, keystore.wallets.count)

        let result = keystore.delete(wallet: wallet)

        guard case .success = result else {
            return XCTFail()
        }

        XCTAssertEqual(0, keystore.wallets.count)
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

        XCTAssertEqual(1, keystore.wallets.count)
    }

    func testSignPersonalMessage() {
        let keystore = FakeEtherKeystore()

        let privateKeyResult = keystore.convertPrivateKeyToKeystoreFile(privateKey: "0x4c0883a69102937d6231471b5dbb6204fe5129617082792ae468d01a3f362318", passphrase: TestKeyStore.password)

        guard case let .success(keystoreString) = privateKeyResult else {
            return XCTFail()
        }

        let result = keystore.importKeystore(
            value: keystoreString.jsonString!,
            password: TestKeyStore.password,
            newPassword: TestKeyStore.password
        )

        guard case let .success(account) = result else {
            return XCTFail()
        }

        let signResult = keystore.signPersonalMessage("Some data".data(using: .utf8)!, for: account)

        guard case let .success(data) = signResult else {
            return XCTFail()
        }

        let expected = Data(hexString: "0xb91467e570a6466aa9e9876cbcd013baba02900b8979d43fe208a4a4f339f5fd6007e74cd82e037b800186422fc2da167c747ef045e5d18a5f5d4300f8e1a0291c")

        XCTAssertEqual(expected, data)

        // web3.eth.accounts.sign('Some data', '0x4c0883a69102937d6231471b5dbb6204fe5129617082792ae468d01a3f362318');
        // expected:
        // message: 'Some data',
        // messageHash: '0x1da44b586eb0729ff70a73c326926f6ed5a25f5b056e7f47fbc6e58d86871655',
        // v: '0x1c',
        // r: '0xb91467e570a6466aa9e9876cbcd013baba02900b8979d43fe208a4a4f339f5fd',
        // s: '0x6007e74cd82e037b800186422fc2da167c747ef045e5d18a5f5d4300f8e1a029',
        // signature: '0xb91467e570a6466aa9e9876cbcd013baba02900b8979d43fe208a4a4f339f5fd6007e74cd82e037b800186422fc2da167c747ef045e5d18a5f5d4300f8e1a0291c'
    }

    func testSignUTF8PersonalMessage() {
        let keystore = FakeEtherKeystore()
        let privateKeyResult = keystore.convertPrivateKeyToKeystoreFile(privateKey: "0xD30519BCAE8D180DBFCC94FE0B8383DC310185B0BE97B4365083EBCECCD75759", passphrase: TestKeyStore.password)

        guard case let .success(keystoreString) = privateKeyResult else {
            return XCTFail()
        }

        let result = keystore.importKeystore(
            value: keystoreString.jsonString!,
            password: TestKeyStore.password,
            newPassword: TestKeyStore.password
        )

        guard case let .success(account) = result else {
            return XCTFail()
        }

        let signResult = keystore.signPersonalMessage("♥".data(using: .utf8)!, for: account)

        guard case let .success(data) = signResult else {
            return XCTFail()
        }

        let expected = Data(hexString: "0x2b3d550f0bf9dce1a6e8ddaa0491317b52baf666fa5edd2940691271df50891933a16253ab2589825a2e1bfe9718c3a27723c51e61a78c28a048b63d9f2baaee1b")

        XCTAssertEqual(expected, data)
    }

    func testSignMessage() {
        let keystore = FakeEtherKeystore()

        let privateKeyResult = keystore.convertPrivateKeyToKeystoreFile(privateKey: "0x4c0883a69102937d6231471b5dbb6204fe5129617082792ae468d01a3f362318", passphrase: TestKeyStore.password)

        guard case let .success(keystoreString) = privateKeyResult else {
            return XCTFail()
        }

        let result = keystore.importKeystore(
            value: keystoreString.jsonString!,
            password: TestKeyStore.password,
            newPassword: TestKeyStore.password
        )

        guard case let .success(account) = result else {
            return XCTFail()
        }

        let signResult = keystore.signPersonalMessage("0x3f44c2dfea365f01c1ada3b7600db9e2999dfea9fe6c6017441eafcfbc06a543".data(using: .utf8)!, for: account)

        guard case let .success(data) = signResult else {
            return XCTFail()
        }

        let expected = Data(hexString: "0x619b03743672e31ad1d7ee0e43f6802860082d161acc602030c495a12a68b791666764ca415a2b3083595aee448402874a5a376ea91855051e04c7b3e4693d201c")

        XCTAssertEqual(expected, data)
    }

    func testSignTypedMessage() {
        let keystore = FakeEtherKeystore()
        let privateKeyResult = keystore.convertPrivateKeyToKeystoreFile(privateKey: "0x4c0883a69102937d6231471b5dbb6204fe5129617082792ae468d01a3f362318", passphrase: TestKeyStore.password)

        guard case let .success(keystoreString) = privateKeyResult else {
            return XCTFail()
        }

        let result = keystore.importKeystore(
            value: keystoreString.jsonString!,
            password: TestKeyStore.password,
            newPassword: TestKeyStore.password
        )

        guard case let .success(account) = result else {
            return XCTFail()
        }

        let typedData = EthTypedData(type: "string", name: "Message", value: .string(value: "Hi, Alice!"))
        let typedData2 = EthTypedData(type: "uint32", name: "A number", value: .uint(value: 1337))

        let signResult = keystore.signTypedMessage([typedData, typedData2], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }
 
        let expected = Data(hexString: "0xb6c1299463ba6f55545311032a6f6164ebcaf36c0d81f7b034a09d81a4a80b8d0cc3810c2433cb173c28593b7d964bea84b29f663fdeec5fb5c83381e5293fd71b")
        XCTAssertEqual(expected, data)
    }

    func testAddWatchAddress() {
        let keystore = FakeEtherKeystore()
        let address: Address = .make()
        keystore.importWallet(type: ImportType.watch(address: address)) {_  in }

        XCTAssertEqual(1, keystore.wallets.count)
        XCTAssertEqual(address, keystore.wallets[0].address)
    }

    func testDeleteWatchAddress() {
        let keystore = FakeEtherKeystore()
        let address: Address = .make()

        // TODO. Move this into sync calls
        keystore.importWallet(type: ImportType.watch(address: address)) { result  in
            switch result {
            case .success(let wallet):
                XCTAssertEqual(1, keystore.wallets.count)
                XCTAssertEqual(address, keystore.wallets[0].address)

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

    func testKeychainKeyPrivateKey() {
        let keystore = FakeEtherKeystore()
        let address = Address(string: "0x5e9c27156a612a2d516c74c7a80af107856f8539")!
        let key = keystore.keychainKey(for: .make(address: address, type: .encryptedKey))

        XCTAssertEqual(key, address.description.lowercased())
    }

    func testKeychainKeyHDWallet() {
        let keystore = FakeEtherKeystore()
        let address = Address(string: "0x5e9c27156a612a2d516c74c7a80af107856f8539")!
        let key = keystore.keychainKey(for: .make(address: address, type: .hierarchicalDeterministicWallet))

        XCTAssertEqual(key, "hd-wallet-" + address.description)
    }


}
