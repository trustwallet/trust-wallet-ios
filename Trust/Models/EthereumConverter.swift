// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct EthereumConverter {

    static func from(
        value: BInt,
        to: EthereumUnit,
        minimumFractionDigits: Int = 3,
        maximumFractionDigits: Int = 3
    ) -> String {
        //TODO: Hack. Implement better solution

        let first = Double(value.dec)!
        let second = Double(to.rawValue)
        let third = first / second

        let number = NSNumber(value: third)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.roundingMode = .floor
        let formattedAmount = formatter.string(from: number)!

        return formattedAmount
    }
}
