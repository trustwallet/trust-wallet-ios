// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt

struct GasViewModel {
    let fee: BigInt
    let server: RPCServer
    let session: WalletSession
    let formatter: EtherNumberFormatter

    init(
        fee: BigInt,
        server: RPCServer,
        session: WalletSession,
        formatter: EtherNumberFormatter = .full
    ) {
        self.fee = fee
        self.server = server
        self.session = session
        self.formatter = formatter
    }

    var etherFee: String {
        let gasFee = formatter.string(from: fee)
        return "\(gasFee.description) \(server.symbol)"
    }

    var feeCurrency: Double? {
        guard let price = session.tokensStorage.coinTicker(by: server.priceID)?.price else {
            return .none
        }
        return FeesCalculations.estimate(fee: formatter.string(from: fee), with: price)
    }

    var monetaryFee: String? {
        guard let feeInCurrency = feeCurrency,
            let fee = FeesCalculations.format(fee: feeInCurrency) else {
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
