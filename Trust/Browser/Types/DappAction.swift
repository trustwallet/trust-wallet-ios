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
                    to: Address(string: "0x0000000000000000000000000000000000000000")!,
                    data: Data()
                )
                return .signTransaction(unconfirmedTransaction)
            } catch {
                NSLog("error \(error)")
                return .unknown
            }
        case .sign:
            return .sign
        case .sendTransaction:

            let to = Address(string: command.object["to"]?.value ?? "")

            let unconfirmedTransaction = UnconfirmedTransaction(
                transferType: .ether(destination: .none),
                value: 0,
                to: to,
                data: Data(hex: command.object["data"]!.value)
            )
            return .signTransaction(unconfirmedTransaction)
        case .unknown:
            return .unknown
        }
    }
}
