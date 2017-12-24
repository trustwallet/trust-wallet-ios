// Copyright SIX DAY LLC. All rights reserved.

import Foundation

class CurrencyFormatter {
    static var formatter: NumberFormatter {
        let formatter = NumberFormatter()
       
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.currencyCode = Config().currency.rawValue
        formatter.numberStyle = .currency
        return formatter
    }

    static var plainFormatter: EtherNumberFormatter {
        let formatter = EtherNumberFormatter.full
        formatter.groupingSeparator = ""
        return formatter
    }
}
