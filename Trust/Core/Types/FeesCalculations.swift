// Copyright DApps Platform Inc. All rights reserved.

import UIKit

struct FeeCalculator {

    static func estimate(fee: String, with price: String) -> Double? {
        guard let feeInDouble = Double(fee) else {
            return nil
        }
        guard let price = Double(price) else {
            return nil
        }
        return price * feeInDouble
    }

    static func format(fee: Double, formatter: NumberFormatter = CurrencyFormatter.formatter) -> String? {
        return formatter.string(from: NSNumber(value: fee))
    }

}
