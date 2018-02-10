// Copyright SIX DAY LLC. All rights reserved.

import Foundation

final class DecimalFormatter {
    /// Locale of a `DecimalFormatter`.
    var locale: Locale
    /// numberFormatter of a `DecimalFormatter` to represent curent locale.
    private lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = self.locale
        formatter.numberStyle = .decimal
        formatter.isLenient = true
        return formatter
    }()
    /// usFormatter of a `DecimalFormatter` to represent decimal separator ".".
    private lazy var usFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.isLenient = true
        return formatter
    }()
    /// frFormatter of a `DecimalFormatter` to represent decimal separator ",".
    private lazy var frFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.numberStyle = .decimal
        formatter.isLenient = true
        return formatter
    }()
    /// enCaFormatter of a `DecimalFormatter` to represent decimal separator "'".
    private lazy var enCaFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_CA")
        formatter.numberStyle = .decimal
        formatter.isLenient = true
        return formatter
    }()
    /// Initializes a `DecimalFormatter` with a `Locale`.
    init(locale: Locale = .current) {
        self.locale = locale
        self.numberFormatter = NumberFormatter()
        self.numberFormatter.locale = self.locale
        self.numberFormatter.numberStyle = .decimal
        self.numberFormatter.isLenient = true
    }
    /// Converts a String to a `NSumber`.
    ///
    /// - Parameters:
    ///   - string: string to convert.
    /// - Returns: `NSumber` represenation.
    func number(from string: String) -> NSNumber? {
        return self.numberFormatter.number(from: string) ?? self.usFormatter.number(from: string) ?? self.frFormatter.number(from: string) ?? self.enCaFormatter.number(from: string)
    }
    /// Converts a NSumber to a `String`.
    ///
    /// - Parameters:
    ///   - number: nsnumber to convert.
    /// - Returns: `NSumber` represenation.
    func string(from number: NSNumber) -> String? {
        return self.numberFormatter.string(from: number)
    }
}
