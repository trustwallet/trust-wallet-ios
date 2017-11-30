// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation

final class EtherNumberFormatter {
    /// Formatter that preserves full precision.
    static let full = EtherNumberFormatter()

    // Formatter that caps the number of decimal digits to 3.
    static let short: EtherNumberFormatter = {
        let formatter = EtherNumberFormatter()
        formatter.maximumFractionDigits = 3
        return formatter
    }()

    /// Minimum number of digits after the decimal point.
    var minimumFractionDigits = 0

    /// Maximum number of digits after the decimal point.
    var maximumFractionDigits = Int.max

    /// Decimal point.
    var decimalSeparator = "."

    /// Thousands separator.
    var groupingSeparator = ","

    /// Initializes a `EtherNumberFormatter` with a `Locale`.
    init(locale: Locale = .current) {
        decimalSeparator = locale.decimalSeparator ?? "."
        groupingSeparator = locale.groupingSeparator ?? ","
    }

    /// Formats a `BigInt` for displaying to the user.
    ///
    /// - Parameters:
    ///   - number: number to format
    ///   - units: units to use
    /// - Returns: string representation
    func string(from number: BigInt, units: EthereumUnit = .ether) -> String {
        precondition(minimumFractionDigits >= 0)
        precondition(maximumFractionDigits >= 0)

        let (integerPart, remainder) = number.quotientAndRemainder(dividingBy: BigInt(units.rawValue))
        let integerString = self.integerString(from: integerPart)
        let fractionalString = self.fractionalString(from: BigInt(sign: .plus, magnitude: remainder.magnitude), units: units)
        if fractionalString.isEmpty {
            return integerString
        }
        return "\(integerString).\(fractionalString)"
    }

    private func integerString(from: BigInt) -> String {
        var string = from.description
        let end = from.sign == .minus ? 1 : 0
        for offset in stride(from: string.count - 3, to: end, by: -3) {
            let index = string.index(string.startIndex, offsetBy: offset)
            string.insert(contentsOf: groupingSeparator, at: index)
        }
        return string
    }

    private func fractionalString(from number: BigInt, units: EthereumUnit) -> String {
        var number = number
        let decimalPlaces = Int(log10(Double(units.rawValue)))
        let digits = number.description.count

        if number == 0 || decimalPlaces - digits > maximumFractionDigits {
            // Value is smaller than can be represented with `maximumFractionDigits`
            return String(repeating: "0", count: minimumFractionDigits)
        }

        if decimalPlaces < minimumFractionDigits {
            number *= BigInt(10).power(minimumFractionDigits - decimalPlaces)
        }
        if decimalPlaces > maximumFractionDigits {
            number /= BigInt(10).power(decimalPlaces - maximumFractionDigits - 1)
            number = (number + 5) / 10 // Make sure that the result is rounded
        }

        var string = number.description
        if digits < decimalPlaces {
            // Pad with zeros at the left if necessary
            string = String(repeating: "0", count: decimalPlaces - digits) + string
        }

        // Remove extra zeros after the decimal point.
        if let lastNonZeroIndex = string.reversed().index(where: { $0 != "0" })?.base {
            let numberOfZeros = string.distance(from: string.startIndex, to: lastNonZeroIndex)
            if numberOfZeros > minimumFractionDigits {
                let newEndIndex = string.index(string.startIndex, offsetBy: numberOfZeros - minimumFractionDigits)
                string = String(string[string.startIndex..<newEndIndex])
            }
        }

        return string
    }
}
