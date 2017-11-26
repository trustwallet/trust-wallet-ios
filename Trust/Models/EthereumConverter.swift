// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation

struct EthereumConverter {

    static func from(
        value: BigInt,
        to: EthereumUnit,
        minimumFractionDigits: Int = 3,
        maximumFractionDigits: Int = 3
    ) -> String {
        precondition(minimumFractionDigits >= 0)
        precondition(maximumFractionDigits >= 0)
        var string = value.description

        // Compute the number of places to shift the decimal point
        let decimalDistance = Int(log10(Double(to.rawValue)))
        if decimalDistance > string.count {
            // Pad with zeros at the left if necessary
            string = String(repeating: "0", count: decimalDistance - string.count + 1) + string
        }

        // Insert decimal point
        let decimalPointIndex = string.index(string.endIndex, offsetBy: -decimalDistance)
        string.insert(".", at: decimalPointIndex)

        if decimalDistance < minimumFractionDigits {
            string += String(repeating: "0", count: minimumFractionDigits - decimalDistance)
        }
        if decimalDistance > maximumFractionDigits {
            string = String(string.dropLast(decimalDistance - maximumFractionDigits))
        }

        // Remove decimal point if there are no decimals
        if string.hasSuffix(".") {
            string = string[string.startIndex..<string.index(before: string.endIndex)]
        }

        return string
    }
}
