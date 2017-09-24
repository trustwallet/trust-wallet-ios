// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import UIKit

struct TransactionsViewModel {

    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var items: [(date: String, transactions: [Transaction])] = []

    init(transactions: [Transaction]) {

        var newItems: [String: [Transaction]] = [:]

        for transaction in transactions {
            let date = TransactionsViewModel.formatter.string(from: transaction.time)

            var currentItems = newItems[date] ?? []
            currentItems.insert(transaction, at: 0)
            newItems[date] = currentItems
        }

        let tuple = newItems.map { (key, values) in return (date: key, transactions: values) }
        items = tuple.sorted { (object1, object2) -> Bool in return object1.date > object2.date }
    }

    var title: String {
        return "~ ETH"
    }

    var backgroundColor: UIColor {
        return .white
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
        if NSCalendar.current.isDateInToday(date) { return "Today" }
        if NSCalendar.current.isDateInYesterday(date) { return "Yesterday" }
        return value
    }
}
