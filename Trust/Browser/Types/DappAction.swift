// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt
import TrustKeystore

enum DappAction {
    case signMessage(String)
    case signTransaction(UnconfirmedTransaction)
    case unknown
}

extension DappAction {
    static func fromCommand(_ command: DappCommand) -> DappAction {
        switch command.name {
        case .signTransaction, .sendTransaction:
            let to = Address(string: command.object["to"]?.value ?? "")
            let value = BigInt((command.object["value"]?.value ?? "0").drop0x, radix: 16) ?? BigInt()

            let unconfirmedTransaction = UnconfirmedTransaction(
                transferType: .ether(destination: .none),
                value: value,
                to: to,
                data: Data(hex: command.object["data"]!.value)
            )
            return .signTransaction(unconfirmedTransaction)
        case .signMessage, .signPersonalMessage:
            NSLog("command.object \(command.object)")
            return .signMessage("")
        case .unknown:
            return .unknown
        }
    }
}
