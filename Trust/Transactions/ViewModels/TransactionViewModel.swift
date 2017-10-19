// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct TransactionViewModel {

    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    let transaction: Transaction

    init(transaction: Transaction) {
        self.transaction = transaction
    }

    var title: String {
        return "Transaction"
    }

    var backgroundColor: UIColor {
        return .white
    }

    var amount: String {
        let value = EthereumConverter.from(value: BInt(transaction.value), to: .ether, minimumFractionDigits: 5)
        switch transaction.direction {
        case .incoming: return "+\(value)"
        case .outgoing: return "-\(value)"
        }
    }

    var createdAt: String {
        return TransactionViewModel.formatter.string(from: transaction.date)
    }
}
