// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import CryptoSwift

protocol Signer {
    func hash(transaction: SignTransaction) -> Data
    func values(transaction: SignTransaction, signature: Data) -> (r: BigInt, s: BigInt, v: BigInt)
}

struct EIP155Signer: Signer {
    let chainId: BigInt

    init(chainId: BigInt) {
        self.chainId = chainId
    }

    func hash(transaction: SignTransaction) -> Data {
        return rlpHash([
            transaction.nonce,
            transaction.gasPrice,
            transaction.gasLimit,
            transaction.address.data,
            transaction.value,
            transaction.data,
            transaction.chainID, 0, 0,
        ] as [Any])!
    }

    func values(transaction: SignTransaction, signature: Data) -> (r: BigInt, s: BigInt, v: BigInt) {
        let (r, s, v) = HomesteadSigner().values(transaction: transaction, signature: signature)
        let newV: BigInt
        if chainId != 0 {
            newV = BigInt(signature[64]) + 35 + chainId + chainId
        } else {
            newV = v
        }
        return (r, s, newV)
    }
}

struct HomesteadSigner: Signer {
    func hash(transaction: SignTransaction) -> Data {
        return rlpHash([
            transaction.nonce,
            transaction.gasPrice,
            transaction.gasLimit,
            transaction.address.data,
            transaction.value,
            transaction.data,
        ])!
    }

    func values(transaction: SignTransaction, signature: Data) -> (r: BigInt, s: BigInt, v: BigInt) {
        precondition(signature.count == 65, "Wrong size for signature")
        let r = BigInt(sign: .plus, magnitude: BigUInt(signature[..<32]))
        let s = BigInt(sign: .plus, magnitude: BigUInt(signature[32..<64]))
        let v = BigInt(sign: .plus, magnitude: BigUInt(signature[64] + 27))
        return (r, s, v)
    }
}

func rlpHash(_ element: Any) -> Data? {
    let sha3 = SHA3(variant: .keccak256)
    guard let data = RLP.encode(element) else {
        return nil
    }
    return Data(bytes: sha3.calculate(for: data.bytes))
}
