// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct TransactionsViewModel {

    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var items: [(date: String, transactions: [Transaction])] = []
    let config: Config

    init(
        transactions: [Transaction] = [],
        config: Config = Config()
    ) {
        self.config = config

        var newItems: [String: [Transaction]] = [:]

        for transaction in transactions {
            let date = TransactionsViewModel.formatter.string(from: transaction.date)

            var currentItems = newItems[date] ?? []
            currentItems.append(transaction)
            newItems[date] = currentItems
        }
        //TODO. IMPROVE perfomance
        let tuple = newItems.map { (key, values) in return (date: key, transactions: values) }
        items = tuple.sorted { (object1, object2) -> Bool in
            return TransactionsViewModel.formatter.date(from: object1.date)! > TransactionsViewModel.formatter.date(from: object2.date)!
        }
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
        return items[section].transactions.count
    }

    func item(for row: Int, section: Int) -> Transaction {
        return items[section].transactions[row]
    }

    func titleForHeader(in section: Int) -> String {
        let value = items[section].date
        let date = TransactionsViewModel.formatter.date(from: value)!
        if NSCalendar.current.isDateInToday(date) {
            return NSLocalizedString("Today", value: "Today", comment: "")
        }
        if NSCalendar.current.isDateInYesterday(date) {
            return NSLocalizedString("Yesterday", value: "Yesterday", comment: "")
        }
        return value
    }

    var isBuyActionAvailable: Bool {
        switch config.server {
        case .main, .kovan, .classic, .ropsten, .poa, .sokol: return false
        }
    }
}
