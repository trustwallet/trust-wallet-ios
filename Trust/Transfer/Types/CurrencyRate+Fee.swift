// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt
import TrustCore

extension CurrencyRate {
    func estimate(fee: String, with address: EthereumAddress) -> Double? {
        guard let feeInDouble = Double(fee) else {
            return nil
        }
        guard let price = self.rates.filter({ $0.contract == address.description }).first else {
            return nil
        }
        return price.price * feeInDouble
    }

    func format(fee: Double, formatter: NumberFormatter = CurrencyFormatter.formatter) -> String? {
        return formatter.string(from: NSNumber(value: fee))
    }
}
