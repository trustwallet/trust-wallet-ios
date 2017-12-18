// Copyright SIX DAY LLC. All rights reserved.

import Foundation

class CurrencyFormatter {
    static var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        //TODO: use current locale when available this feature
        formatter.locale = Locale(identifier: "en_US")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .currency
        return formatter
    }

    static var plainFormatter: EtherNumberFormatter {
        var formatter = EtherNumberFormatter.full
        formatter.groupingSeparator = ""
        return formatter
    }
}
