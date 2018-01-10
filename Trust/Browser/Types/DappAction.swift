// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt
import TrustKeystore

enum DappAction {
    case sign
    case signTransaction(UnconfirmedTransaction)
    case unknown
}

extension DappAction {
    static func fromCommand(_ command: DappCommand) -> DappAction {
        let decoder = JSONDecoder()
        switch command.name {
        case .signTransaction:
            do {
                let transaction = try decoder.decode(
                    SendTransaction.self,
                    from: command.object.jsonString!.data(using: .utf8)!
                )
                let unconfirmedTransaction = UnconfirmedTransaction(
                    transferType: .ether(destination: .none),
                    value: BigInt(transaction.value ?? "0", radix: 10) ?? BigInt(0),
                    address: Address(string: "0x0000000000000000000000000000000000000000"),
                    account: Account(address: Address(string: "0x0000000000000000000000000000000000000000")),
                    chainID: 1,
                    data: Data()
                )
                return .signTransaction(unconfirmedTransaction)
            } catch {
                NSLog("error \(error)")
                return .unknown
            }
        case .sign:
            return .sign
        }
    }
}
