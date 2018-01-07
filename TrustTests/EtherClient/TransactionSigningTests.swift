// Copyright SIX DAY LLC. All rights reserved.

import BigInt
@testable import Trust
import XCTest

class TransactionSigningTests: XCTestCase {
    func testEIP155SignHash() {
        let address = Address(address: "0x3535353535353535353535353535353535353535")
        let transaction = SignTransaction(
            value: BigInt("1000000000000000000"),
            account: Account(address: address),
            address: address,
            nonce: 9,
            data: Data(),
            gasPrice: BigInt("20000000000"),
            gasLimit: BigInt("21000"),
            chainID: 1)
        let signer = EIP155Signer(chainId: 1)
        let hash = signer.hash(transaction: transaction)

        XCTAssertEqual(hash.hex, "daf5a779ae972f972197303d7b574746c7ef83eadac0f2791ad23db92e4c8e53")
    }

    func testHomesteadSignHash() {
        let address = Address(address: "0x3535353535353535353535353535353535353535")
        let transaction = SignTransaction(
            value: BigInt("1000000000000000000"),
            account: Account(address: address),
            address: address,
            nonce: 9,
            data: Data(),
            gasPrice: BigInt("20000000000"),
            gasLimit: BigInt("21000"),
            chainID: 1)
        let signer = HomesteadSigner()
        let hash = signer.hash(transaction: transaction)

        XCTAssertEqual(hash.hex, "f9e36c28c8cb35adba138005c02ab7aa7fbcd891f3139cb2eeed052a51cd2713")
    }
}
