// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import Trust
import TrustCore
import TrustKeystore

class EIP712TypedDataTests: XCTestCase {
    var typedData: EIP712TypedData!

    override func setUp() {
        super.setUp()
        let string = """
{
    "types": {
        "EIP712Domain": [
            {"name": "name", "type": "string"},
            {"name": "version", "type": "string"},
            {"name": "chainId", "type": "uint256"},
            {"name": "verifyingContract", "type": "address"}
        ],
        "Person": [
            {"name": "name", "type": "string"},
            {"name": "wallet", "type": "address"}
        ],
        "Mail": [
            {"name": "from", "type": "Person"},
            {"name": "to", "type": "Person"},
            {"name": "contents", "type": "string"}
        ]
    },
    "primaryType": "Mail",
    "domain": {
        "name": "Ether Mail",
        "version": "1",
        "chainId": 1,
        "verifyingContract": "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC"
    },
    "message": {
        "from": {
            "name": "Cow",
            "wallet": "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826"
        },
        "to": {
            "name": "Bob",
            "wallet": "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB"
        },
        "contents": "Hello, Bob!"
    }
}
"""
        let data = string.data(using: .utf8)!
        let decoder = JSONDecoder()

        typedData = try? decoder.decode(EIP712TypedData.self, from: data)
    }

    func testDecodeJSONModel() {
        XCTAssertNotNil(typedData)
    }

    func testEncodeType() {
        let result = "Mail(Person from,Person to,string contents)Person(string name,address wallet)"
        XCTAssertEqual(typedData.encodeType(primaryType: "Mail"), result.data(using: .utf8)!)
    }

    func testEncodedTypeHash() {
        let result = "0xa0cedeb2dc280ba39b857546d74f5549c3a1d7bdc2dd96bf881f76108e23dac2"
        XCTAssertEqual(typedData.typeHash.hexEncoded, result)
    }

    func testEncodeData() {
        let result = "0xa0cedeb2dc280ba39b857546d74f5549c3a1d7bdc2dd96bf881f76108e23dac2fc71e5fa27ff56c350aa531bc129ebdf613b772b6604664f5d8dbe21b85eb0c8cd54f074a4af31b4411ff6a60c9719dbd559c221c8ac3492d9d872b041d703d1b5aadf3154a261abdd9086fc627b61efca26ae5702701d05cd2305f7c52a2fc8"
        let data = typedData.encodeData(data: typedData.message, type: "Mail")
        XCTAssertEqual(data.hexEncoded, result)
    }

    func testStructHash() {
        let result = "0xc52c0ee5d84264471806290a3f2c4cecfc5490626bf912d01f240d7a274b371e"
        let data = typedData.encodeData(data: typedData.message, type: "Mail")
        XCTAssertEqual(Crypto.hash(data).hexEncoded, result)

        let result2 = "0xf2cee375fa42b42143804025fc449deafd50cc031ca257e0b194a650a912090f"
//        let json = try! JSONDecoder().decode(JSON.self, from: try! JSONEncoder().encode(typedData.domain))
        let data2 = typedData.encodeData(data: typedData.domain, type: "EIP712Domain")
        XCTAssertEqual(Crypto.hash(data2).hexEncoded, result2)
    }

    func testSignHash() {
        let cow = "cow".data(using: .utf8)!
        let privateKeyData = Crypto.hash(cow)
        let privateKey = PrivateKey(data: privateKeyData)!

        let result = "0xbe609aee343fb3c4b28e1df9e632fca64fcfaede20f02e86244efddf30957bd2"
        let address = "0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826"
        let signed = Crypto.sign(hash: typedData.signHash, privateKey: privateKeyData)

        XCTAssertEqual(privateKey.publicKey(for: .ethereum).address.description.lowercased(), address)
        XCTAssertEqual(typedData.signHash.hexEncoded, result)
        XCTAssertEqual(signed.hexEncoded, "0x4355c47d63924e8a72e509b65029052eb6c299d53a04e167c5775fd466751c9d07299936d304c153f6443dfa05f40ff007d72911b6f72307f996231605b9156201")
    }
}
