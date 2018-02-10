// Copyright SIX DAY LLC. All rights reserved.

import Foundation

final class DecimalFormatter {
    /// Locale of a `DecimalFormatter`.
    var locale: Locale
    /// numberFormatter of a `DecimalFormatter`.
    private var numberFormatter: NumberFormatter
    /// usLocale of a `DecimalFormatter` to represent decimal separator ".".
    private let usLocale = Locale(identifier: "en_US")
    /// usLocale of a `DecimalFormatter` to represent decimal separator ",".
    private let frLocale = Locale(identifier: "fr_FR")
    /// enCaLocale of a `DecimalFormatter` to represent decimal separator "'".
    private let enCaLocale = Locale(identifier: "en_CA")
    /// locales of a `DecimalFormatter` to check locale inconsistency.
    private lazy var locales: [Locale] = {
        return [locale, usLocale, frLocale, enCaLocale]
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
        return self.numberFormatter.number(from: self.validation(for: string))
    }
    /// Converts a NSumber to a `String`.
    ///
    /// - Parameters:
    ///   - number: nsnumber to convert.
    /// - Returns: `NSumber` represenation.
    func string(from number: NSNumber) -> String? {
        return self.numberFormatter.string(from: number)
    }
    
    /// Validate string for the locale inconsistency.
    ///
    /// - Parameters:
    ///   - string: string to validate.
    /// - Returns: valid `String`.
    private func validation(for string: String) -> String {
        for locale in locales {
            self.numberFormatter.locale = locale
            if self.numberFormatter.number(from: string) != nil {
                return string
            }
        }
        return string
    }
}
