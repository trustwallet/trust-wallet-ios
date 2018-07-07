// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust
import TrustCore
import TrustKeystore
import KeychainSwift

class TypedMessageEncodingTests: XCTestCase {

    var account: Account!
    let keystore = FakeEtherKeystore()

    override func setUp() {
        super.setUp()
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
        self.account = account
    }

    func testValue_none() {
        let typedData = EthTypedData(type: "string", name: "test test", value: .none)
        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }
        XCTAssertEqual(data.hexEncoded, "0xd8cb0766acdfeb460b3e88173d71e223e31a442d468a6ceec85eb60b2cdf69dd62cc0a14e8c205eed582d47fac726850e43149844c81965a18ddee7a627c6ffb1b")
    }

    func testValues() {
        let typedData = EthTypedData(type: "string", name: "Message", value: .string(value: "Hi, Alice!"))
        let typedData2 = EthTypedData(type: "uint8", name: "value", value: .uint(value: 10))
        let signResult = keystore.signTypedMessage([typedData, typedData2], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }
        XCTAssertEqual(data.hexEncoded, "0xfff29ccbfcd4a2a19fc43fbb803a09facaf3c6363f017cc57201b71a96facbc25200460d266b6a5ec0e42a79271593b95faf067f25a569e7465a169240fac0b91b")
    }

    func testType_uint_Value_uint() {
        // from https://beta.adex.network/
        let typedData = EthTypedData(type: "uint", name: "Auth token", value: .uint(value: 1498316044249108))

        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }
        XCTAssertEqual(data.hexEncoded, "0xa1f639ae9e97401030fb4205749fe8b8e72602624aa92aa0558129b345e9546c42f3bcb7b71c83b7474cb93d83913249708570af9120cf9655775fea9571e0481b")
    }

    func testType_uint_Value_string() {
        // from https://beta.adex.network/
        let typedData = EthTypedData(type: "uint", name: "Auth token", value: .string(value: "1498316044249108"))

        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }
        XCTAssertEqual(data.hexEncoded, "0xa1f639ae9e97401030fb4205749fe8b8e72602624aa92aa0558129b345e9546c42f3bcb7b71c83b7474cb93d83913249708570af9120cf9655775fea9571e0481b")
    }

    func testType_bool_Value_bool() {
        let typedData = EthTypedData(type: "bool", name: "email valid", value: .bool(value: false))
        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }
        XCTAssertEqual(data.hexEncoded, "0x1df23825a6c4ea9b1782754da23c21c6af1732fe614cbcdf34a4daefbaddf47c444891aad02c2d4bab0df228fb4852d6620d624a9848e432f7141fe5a89e7e171c")
    }

    func testType_address_Value_string() {
        let typedData = EthTypedData(type: "address", name: "my address", value: .address(value: "0x2c7536e3605d9c16a7a3d7b1898e529396a65c23"))
        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }
        XCTAssertEqual(data.hexEncoded, "0xe218514cddfeba69a1fe7fac5af54193e357e8fb5644239045ed65e4e950d564412c6bf6d571fafb73bdd23ef71e8269242b001ca3ecb1a6661fcb70eaacf25c1b")
    }

    func testType_string_Value_string() {
        let typedData = EthTypedData(type: "string", name: "This is a message", value: .string(value: "hello bob"))
        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }
        XCTAssertEqual(data.hexEncoded, "0x8b5194f65b8f2fb8ef110391bcecde9bc97a41dae833c69aa1f6486d910a7d870056f784a386d7a9416315692e0da7a78702d95d308b4381c21d60d93dbc7e061c")
    }

    func testType_string_Value_emptyString() {
        let typedData = EthTypedData(type: "string", name: "empty string here!", value: .string(value: ""))
        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }
        XCTAssertEqual(data.hexEncoded, "0xbf9ee06fd0f62fd385d5eeb091efaa636c808cc315f40c48f945138ed4cd1458547cdaf8a4cd8ddd4949a5441910a94cd2a18e9dbc4183c93804299a79335e451c")
    }

    func testType_int_Value_int() {
        let typedData = EthTypedData(type: "int32", name: "how much?", value: .int(value: 1200))
        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }
        XCTAssertEqual(data.hexEncoded, "0xe6d4d981485013055ee978c39cf9c18096b4e05bc0471de72377db9b392c7582276d2d8e7b6329f784aac8fbd42417c74906285e072019e025883e52f94a169d1c")
    }

    func testType_int_Value_bigInt() {
        // from https://like.co/
        let typedData = EthTypedData(type: "int256", name: "how much?", value: .string(value: "-57896044618658097711785492504343953926634992332820282019728792003956564819968"))
        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }
        XCTAssertEqual(data.hexEncoded, "0xa1cd93b6dd2a18748993c727c8c9be20a784504b7f1fc9eece228bc5004e805d6a0bcabce62994881b562243ace5cc3ce18bd41302c793dce38c301036af01761c")
    }

    func testType_int_Value_bigUInt() {
        // from https://like.co/
        let typedData = EthTypedData(type: "uint256", name: "how much?", value: .string(value: "6739986666787659948666753771754907668409286105635143120275902562304"))
        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }
        XCTAssertEqual(data.hexEncoded, "0xb88c74fd791b6f1e201c8bb08ff977a938d9ca379f83fd00140f683f3a04fcf6220db28ff750efafc642b525d00d0e3e37d2a1af8cd50940306e690f5b93c8d81c")
    }
    
    func testType_bytes_Value_hexString() {
        let typedData = EthTypedData(type: "bytes", name: "your address", value: .string(value: "0x2c7536e3605d9c16a7a3d7b1898e529396a65c23"))
        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }

        XCTAssertEqual(data.hexEncoded, "0x5da07ffb693a23caced43cb9056667a32078d64b24aa2591d2b9c56527b6556e29fbe0807dee0d55c16e85d83edc7bbe972234fa5580a4f4f23f0280c875c8461c")
    }

    func testType_bytes_Value_hexShortString() {
        let typedData = EthTypedData(type: "bytes", name: "short hex", value: .string(value: "0xdeadbeaf"))
        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }

        XCTAssertEqual(data.hexEncoded, "0x740a918cfbfe75a38634a84f2e2c7f33698465ff0332290d5df9b021cbf336cb2593dd11708cdba302d3281223a5db148eda61ef6bd8a32a9f3f2daaa064e72b1c")
    }

    func testType_bytes_Value_hexEmptyString() {
        let typedData = EthTypedData(type: "bytes", name: "empty hex", value: .string(value: "0x"))
        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }

        XCTAssertEqual(data.hexEncoded, "0x342400b5d6a29da301b207df4aab507006ca093cf6d3a690c450524272cf647e0dc013fd29ce1b3fb1292c8af16fc4f1c38777c3acf4a1019c1b7d400aabd1941c")
    }

    func testType_bytes_Value_string() {
        let typedData = EthTypedData(type: "bytes", name: "+bytes in string", value: .string(value: "this is a raw string"))
        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }

        XCTAssertEqual(data.hexEncoded, "0x6f3dc47a034c49f235998b2d460b0bcee7b01fe02d90841bfc2962fb6ec27d003e16fd619f69c85c9360fbe39b2232e5ab8e313c2074bf8c358feade940d289c1b")
    }

    func testType_bytes_Value_emptyString() {
        let typedData = EthTypedData(type: "bytes", name: "nothing here", value: .string(value: ""))
        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }

        XCTAssertEqual(data.hexEncoded, "0x30c390c4579cf166d2b61b7ec7b776219ff6ef44c5171d831b258614e9b00cf14f4ecc01c322cd94c3ef277252a4664f458eaba09e0e91bc63f4eedb145ff8851c")
    }

    func testType_bytes_Value_int() {
        let typedData = EthTypedData(type: "bytes", name: "a number?", value: .uint(value: 1100))
        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }

        XCTAssertEqual(data.hexEncoded, "0xd90e257771b64fbc4ecd963f27ea371eb6a656c1912afda8a9184a4b81130dd71487f525d1ecca0d6008530c1bfcf5afc0c2224670ae68080d264ec96468c9bb1c")
    }
}
