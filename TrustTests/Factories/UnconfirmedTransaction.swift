// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust
import TrustCore
import BigInt

extension UnconfirmedTransaction {
    static func make(
        transferType: Transfer = .ether(destination: .none),
        value: BigInt = BigInt(1),
        to: EthereumAddress = .make(),
        data: Data = Data(),
        gasLimit: BigInt? = BigInt(100000),
        gasPrice: BigInt? = BigInt(1000),
        nonce: BigInt? = BigInt(1)
    ) -> UnconfirmedTransaction {
        return UnconfirmedTransaction(
            transferType: transferType,
            value: value,
            to: to,
            data: data,
            gasLimit: gasLimit,
            gasPrice: gasPrice,
            nonce: nonce
        )
    }
    static func makeToken(
        transferType: Transfer = .token( TokenObject(contract: "0xe41d2489571d322189246dafa5ebde1f4699f498", name: "0x project", symbol: "ZRX", decimals: 6, value: "30000000", isCustom: true, isDisabled: false)),
        value: BigInt = BigInt(6),
        to: EthereumAddress = .make(),
        data: Data = Data(),
        gasLimit: BigInt? = BigInt(100000),
        gasPrice: BigInt? = BigInt(1000),
        nonce: BigInt? = BigInt(1)
        ) -> UnconfirmedTransaction {
        return UnconfirmedTransaction(
            transferType: transferType,
            value: value,
            to: to,
            data: data,
            gasLimit: gasLimit,
            gasPrice: gasPrice,
            nonce: nonce
        )
    }
    static func makeNotEnoughtToken(
        transferType: Transfer = .token( TokenObject(contract: "0xe41d2489571d322189246dafa5ebde1f4699f498", name: "0x project", symbol: "ZRX", decimals: 6, value: "30000000", isCustom: true, isDisabled: false)),
        value: BigInt = BigInt(9000000000000),
        to: EthereumAddress = .make(),
        data: Data = Data(),
        gasLimit: BigInt? = BigInt(100000),
        gasPrice: BigInt? = BigInt(1000),
        nonce: BigInt? = BigInt(1)
        ) -> UnconfirmedTransaction {
        return UnconfirmedTransaction(
            transferType: transferType,
            value: value,
            to: to,
            data: data,
            gasLimit: gasLimit,
            gasPrice: gasPrice,
            nonce: nonce
        )
    }
}
