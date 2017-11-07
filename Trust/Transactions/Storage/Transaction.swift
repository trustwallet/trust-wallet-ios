// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class Transaction: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var owner: String = ""
    @objc dynamic var chainID: Int = 1
    @objc dynamic var state: Int = TransactionState.pending.rawValue
    @objc dynamic var blockNumber: Int64 = 0
    @objc dynamic var from = ""
    @objc dynamic var to = ""
    @objc dynamic var value = ""
    @objc dynamic var gas = ""
    @objc dynamic var gasPrice = ""
    @objc dynamic var gasUsed = ""
    @objc dynamic var nonce: String = ""
    @objc dynamic var date = Date()
    @objc dynamic var actionJSON: String = ""

    convenience init(
        id: String,
        owner: String,
        chainID: Int,
        state: TransactionState,
        blockNumber: Int64,
        from: String,
        to: String,
        value: String,
        gas: String,
        gasPrice: String,
        gasUsed: String,
        nonce: String,
        date: Date,
        actionJSON: String
    ) {
        self.init()
        self.id = id
        self.owner = owner
        self.chainID = chainID
        self.state = state.rawValue
        self.blockNumber = blockNumber
        self.from = from
        self.to = to
        self.value = value
        self.gas = gas
        self.gasPrice = gasPrice
        self.gasUsed = gasUsed
        self.nonce = nonce
        self.date = date
        self.actionJSON = actionJSON
    }

    override static func primaryKey() -> String? {
        return "id"
    }

    var action: TransactionAction? {
        guard let dict = actionJSON.asDictionary as? [String: AnyObject] else { return .none }
        guard let type = dict["type"] as? String else { return .none }

        return .none
    }
}

extension Transaction {
    var direction: TransactionDirection {
        if owner == from { return .outgoing }
        return .incoming
    }

    var transactionState: TransactionState {
        return .completed
    }
}
