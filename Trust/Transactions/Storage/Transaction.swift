// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class Transaction: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var owner: String = ""
    @objc dynamic var state: Int = TransactionState.pending.rawValue
    @objc dynamic var blockNumber = ""
    @objc dynamic var transactionIndex = ""
    @objc dynamic var from = ""
    @objc dynamic var to = ""
    @objc dynamic var value = ""
    @objc dynamic var gas = ""
    @objc dynamic var gasPrice = ""
    @objc dynamic var gasUsed = ""
    @objc dynamic var confirmations: Int64 = 0
    @objc dynamic var nonce: String = ""
    @objc dynamic var date = Date()

    convenience init(
        id: String,
        owner: String,
        state: TransactionState,
        blockNumber: String,
        transactionIndex: String,
        from: String,
        to: String,
        value: String,
        gas: String,
        gasPrice: String,
        gasUsed: String,
        confirmations: Int64,
        nonce: String,
        date: Date
    ) {
        self.init()
        self.id = id
        self.owner = owner
        self.state = state.rawValue
        self.blockNumber = blockNumber
        self.transactionIndex = transactionIndex
        self.from = from
        self.to = to
        self.value = value
        self.gas = gas
        self.gasPrice = gasPrice
        self.gasUsed = gasUsed
        self.confirmations = confirmations
        self.nonce = nonce
        self.date = date
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension Transaction {
    var direction: TransactionDirection {
        if owner == from { return .outgoing }
        return .incoming
    }

    var transactionState: TransactionState {
        if confirmations == 0 {
            return .pending
        }
        return .completed
    }
}
