// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class Transaction: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var blockNumber: Int = 0
    @objc dynamic var from = ""
    @objc dynamic var to = ""
    @objc dynamic var value = ""
    @objc dynamic var gas = ""
    @objc dynamic var gasPrice = ""
    @objc dynamic var gasUsed = ""
    @objc dynamic var nonce: String = ""
    @objc dynamic var date = Date()
    @objc dynamic var internalState: Int = TransactionState.completed.rawValue
    var localizedOperations = List<LocalizedOperationObject>()

    convenience init(
        id: String,
        blockNumber: Int,
        from: String,
        to: String,
        value: String,
        gas: String,
        gasPrice: String,
        gasUsed: String,
        nonce: String,
        date: Date,
        localizedOperations: [LocalizedOperationObject],
        state: TransactionState
    ) {

        self.init()
        self.id = id
        self.blockNumber = blockNumber
        self.from = from
        self.to = to
        self.value = value
        self.gas = gas
        self.gasPrice = gasPrice
        self.gasUsed = gasUsed
        self.nonce = nonce
        self.date = date
        self.internalState = state.rawValue

        let list = List<LocalizedOperationObject>()
        localizedOperations.forEach { element in
            list.append(element)
        }

        self.localizedOperations = list
    }

    convenience init(
        id: String,
        date: Date,
        state: TransactionState
    ) {
        self.init()
        self.id = id
        self.date = date
        self.internalState = state.rawValue
    }

    override static func primaryKey() -> String? {
        return "id"
    }

    var state: TransactionState {
        return TransactionState(int: self.internalState)
    }
}

extension Transaction {
    var operation: LocalizedOperationObject? {
        return localizedOperations.first
    }
}
