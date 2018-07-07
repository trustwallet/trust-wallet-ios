// Copyright DApps Platform Inc. All rights reserved.

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

    var etherFee: String {
        let gasFee = formatter.string(from: fee)
        return "\(gasFee.description) \(server.symbol)"
    }

    var feeCurrency: Double? {
        return currencyRate?.estimate(fee: formatter.string(from: fee), with: server.address)
    }

    var monetaryFee: String? {
        guard let feeInCurrency = feeCurrency,
            let fee = currencyRate?.format(fee: feeInCurrency) else {
            return .none
        }
        return fee
    }

    var feeText: String {
        var text = etherFee
        if let monetaryFee = monetaryFee {
            text += "(\(monetaryFee))"
        }
        return text
    }
}
