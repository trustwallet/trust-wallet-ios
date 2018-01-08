// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import CryptoSwift

protocol Signer {
    func hash(transaction: SignTransaction) -> Data
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
}

func rlpHash(_ element: Any) -> Data? {
    let sha3 = SHA3(variant: .keccak256)
    guard let data = RLP.encode(element) else {
        return nil
    }
    return Data(bytes: sha3.calculate(for: data.bytes))
}
