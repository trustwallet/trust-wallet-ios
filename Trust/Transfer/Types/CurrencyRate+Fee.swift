// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

extension CurrencyRate {
    func estimate(fee: String, with symbol: String) -> String? {
        guard let feeInDouble = Double(fee) else {
            return nil
        }
        guard let price = self.rates.filter({ $0.code == symbol }).first else {
            return nil
        }
        let formattedFee = CurrencyFormatter.formatter.string(from: NSNumber(value: price.price * feeInDouble))
        return formattedFee
    }
}
