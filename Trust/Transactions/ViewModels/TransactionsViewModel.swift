// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct TransactionsSectionModel {
    var header: String
    var items: [Transaction]
}

struct TransactionsViewModel {

    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var items: [TransactionsSectionModel] = []
    let config: Config

    init(
        transactions: [Transaction] = [],
        config: Config = Config()
    ) {
        self.config = config
        guard !transactions.isEmpty else {
            return
        }
        self.prepareSections(for: transactions)
    }

    var backgroundColor: UIColor {
        return .white
    }

    var headerBackgroundColor: UIColor {
        return UIColor(hex: "fafafa")
    }

    var headerTitleTextColor: UIColor {
        return UIColor(hex: "555357")
    }

    var headerTitleFont: UIFont {
        return UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
    }

    var headerBorderColor: UIColor {
        return UIColor(hex: "e1e1e1")
    }

    var numberOfSections: Int {
        return items.count
    }

    func numberOfItems(for section: Int) -> Int {
        return items[section].items.count
    }

    func item(for row: Int, section: Int) -> Transaction {
        return items[section].items[row]
    }

    func titleForHeader(in section: Int) -> String {
        let value = items[section].header
        let date = TransactionsViewModel.formatter.date(from: value)!
        if NSCalendar.current.isDateInToday(date) {
            return NSLocalizedString("Today", value: "Today", comment: "")
        }
        if NSCalendar.current.isDateInYesterday(date) {
            return NSLocalizedString("Yesterday", value: "Yesterday", comment: "")
        }
        return value
    }
    private mutating func prepareSections(for transactions: [Transaction]) {
        let headerDates = NSOrderedSet(array: transactions.map { TransactionsViewModel.formatter.string(from: $0.date ) })
        headerDates.forEach {
            guard let dateKey = $0 as? String else {
                return
            }
            let filteredTransactionByDate = transactions.filter { TransactionsViewModel.formatter.string(from: $0.date ) == dateKey }
            items.append(TransactionsSectionModel( header: dateKey, items: filteredTransactionByDate ))
        }
    }
    var isBuyActionAvailable: Bool {
        switch config.server {
        case .main, .kovan, .classic, .callisto, .ropsten, .rinkeby, .poa, .sokol, .custom: return false
        }
    }
}
