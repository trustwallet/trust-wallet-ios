// Copyright DApps Platform Inc. All rights reserved.

import UIKit

final class StringFormatter {
    /// currencyFormatter of a `StringFormatter` to represent curent locale.
    private lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.currencySymbol = ""
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .currencyAccounting
        formatter.isLenient = true
        return formatter
    }()
    /// decimalFormatter of a `StringFormatter` to represent curent locale.
    private lazy var decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        formatter.isLenient = true
        return formatter
    }()
    /// tenthFormatter of a `StringFormatter` to represent Int numbers with grouping.
    private lazy var tenthFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter
    }()
    /// Converts a Decimal to a `currency String`.
    ///
    /// - Parameters:
    ///   - value: Decimal to convert.
    ///   - currencyCode: code of the currency.
    /// - Returns: Currency `String` represenation.
    func currency(with value: Decimal, and currencyCode: String) -> String {
        let formatter = currencyFormatter
        formatter.currencyCode = currencyCode
        return formatter.string(for: value) ?? "\(value)"
    }
    /// Converts a Decimal to a `token String`.
    ///
    /// - Parameters:
    ///   - value: Decimal to convert.
    ///   - decimals: symbols after coma.
    /// - Returns: Token `String` represenation.
    func token(with value: Decimal, and decimals: Int) -> String {
        let formatter = decimalFormatter
        formatter.maximumFractionDigits = decimals
        return formatter.string(for: value) ?? "\(value)"
    }
    /// Converts a String to a `Decimal`.
    ///
    /// - Parameters:
    ///   - value: String to convert.
    /// - Returns: Decimal represenation.
    func decimal(with value: String) -> Decimal? {
        let formatter = decimalFormatter
        formatter.generatesDecimalNumbers = true
        formatter.decimalSeparator = Locale.current.decimalSeparator
        return formatter.number(from: value) as? Decimal
    }
    /// Converts a Double to a `String`.
    ///
    /// - Parameters:
    ///   - double: double to convert.
    ///   - precision: symbols after coma.
    /// - Returns: `String` represenation.
    func formatter(for double: Double, with precision: Int) -> String {
        return String(format: "%.\(precision)f", double)
    }
    /// Converts a Double to a `String`.
    ///
    /// - Parameters:
    ///   - double: double to convert.
    /// - Returns: `String` represenation.
    func formatter(for double: Double) -> String {
        return String(format: "%f", double)
    }
    /// Converts a Int to a `String` that respect tenth.
    ///
    /// - Parameters:
    ///   - int: int to convert.
    /// - Returns: `String` represenation.
    func formatter(for int: Int) -> String? {
        let formatter = tenthFormatter
        return formatter.string(from: NSNumber(value: int))
    }
}
