// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

extension CurrencyRate {
    func estimate(fee: String, with address: String) -> Double? {
        guard let feeInDouble = Double(fee) else {
            return nil
        }
        guard let price = self.rates.filter({ $0.contract == address }).first else {
            return nil
        }
        return price.price * feeInDouble
    }

    func format(fee: Double, formatter: NumberFormatter = CurrencyFormatter.formatter) -> String? {
        return formatter.string(from: NSNumber(value: fee))
    }
}
