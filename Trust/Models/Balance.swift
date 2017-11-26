// Copyright SIX DAY LLC. All rights reserved.

import Foundation

protocol BalanceProtocol {
    var amount: String { get }
}

struct TokenBalance: BalanceProtocol {

    let token: ExchangeToken
    let data: String

    init(token: ExchangeToken, data: String) {
        self.token = token
        self.data = data
    }

    var amount: String {
        return TokensFormatter.from(token: token, amount: data) ?? ""
    }
}

struct Balance: BalanceProtocol {

    let value: BInt

    init(value: BInt) {
        self.value = value
    }

    var isZero: Bool {
        return value.isZero()
    }

    var wei: String {
        return EthereumConverter.from(value: value, to: .wei, minimumFractionDigits: 2)
    }

    var amount: String {
        return EthereumConverter.from(value: value, to: .ether, minimumFractionDigits: 4)
    }
}

extension String {
    var drop0x: String {
        if self.count > 2 && self.substring(with: 0..<2) == "0x" {
            return String(self.dropFirst(2))
        }
        return self
    }

    var add0x: String {
        return "0x" + self
    }
}
