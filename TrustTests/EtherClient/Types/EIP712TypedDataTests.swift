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
        XCTAssertEqual(typedData.encodeType(primaryType: "Mail"), result)
    }
}
