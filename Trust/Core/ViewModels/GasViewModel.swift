// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

struct GasViewModel {
    let fee: BigInt
    let server: RPCServer
    let currencyRate: CurrencyRate?
    let formatter: EtherNumberFormatter

    init(
        fee: BigInt,
        server: RPCServer,
        currencyRate: CurrencyRate? = nil,
        formatter: EtherNumberFormatter = .full
    ) {
        self.fee = fee
        self.server = server
        self.currencyRate = currencyRate
        self.formatter = formatter
    }

    var feeText: String {
        let gasFee = formatter.string(from: fee)
        var text = "\(gasFee.description) \(server.symbol)"

        if let feeInCurrency = currencyRate?.estimate(fee: gasFee, with: server.address),
            let result = currencyRate?.format(fee: feeInCurrency) {
            text += " (\(result))"
        }
        return text
    }
}
