// Copyright DApps Platform Inc. All rights reserved.

import Foundation

extension EtherNumberFormatter {
    static let balance: EtherNumberFormatter = {
        let formatter = EtherNumberFormatter()
        formatter.maximumFractionDigits = 7
        return formatter
    }()
}
