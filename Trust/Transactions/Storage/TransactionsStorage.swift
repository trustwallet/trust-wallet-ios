// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift
import TrustKeystore

class TransactionsStorage {

    let realm: Realm

    var transactionsCategory: Results<TransactionCategory> {
        return realm.objects(TransactionCategory.self).sorted(byKeyPath: "date", ascending: false)
    }

    init(
        realm: Realm
    ) {
        self.realm = realm
    }

    var objects: [Transaction] {
        return realm.objects(Transaction.self)
            .sorted(byKeyPath: "date", ascending: false)
            .filter { !$0.id.isEmpty }
    }

    var completedObjects: [Transaction] {
        return objects.filter { $0.state == .completed }
    }

    var pendingObjects: [Transaction] {
        return objects.filter { $0.state == TransactionState.pending }
    }

    func get(forPrimaryKey: String) -> Transaction? {
        return realm.object(ofType: Transaction.self, forPrimaryKey: forPrimaryKey)
    }

    func add(_ items: [Transaction]) {
        let trnasactions = transactionCategory(for: items)
        try! realm.write {
            realm.add(trnasactions, update: true)
        }
    }

    private func tokens(from transactions: [Transaction]) -> [Token] {
        let tokens: [Token] = transactions.flatMap { transaction in
            guard
                let operation = transaction.localizedOperations.first,
                let contract = Address(string: operation.contract ?? ""),
                let name = operation.name,
                let symbol = operation.symbol
                else { return nil }
            return Token(
                address: contract,
                name: name,
                symbol: symbol,
                decimals: operation.decimals
            )
        }
        return tokens
    }

    private func transactionCategory(for transactions: [Transaction]) -> [TransactionCategory] {
        var category = [TransactionCategory]()
        let headerDates = NSOrderedSet(array: transactions.map { TransactionsViewModel.realmBaseFormmater.string(from: $0.date ) })
        headerDates.forEach {
            guard let stringDate = $0 as? String, let date = TransactionsViewModel.convert(stringDate) else {
                return
            }
            var pendingTransactions = pendingObjects.filter { TransactionsViewModel.realmBaseFormmater.string(from: $0.date ) == stringDate }
            let filteredTransactionByDate = transactions.filter { TransactionsViewModel.realmBaseFormmater.string(from: $0.date ) == stringDate }
            pendingTransactions.append(contentsOf: filteredTransactionByDate)
            let item = TransactionCategory()
            item.title = stringDate
            item.date = date
            item.transactions.append(objectsIn: pendingTransactions)
            category.append(item)
        }
        return category
    }

    func delete(_ items: [Transaction]) {
        try! realm.write {
            realm.delete(items)
        }
    }

    func update(state: TransactionState, for transaction: Transaction) {
        try! realm.write {
            let tempObject = transaction
            tempObject.internalState = state.rawValue
            realm.add(tempObject, update: true)
        }
    }

    func removeTransactions(for states: [TransactionState]) {
        let objects = realm.objects(Transaction.self).filter { states.contains($0.state) }
        try! realm.write {
            realm.delete(objects)
        }
    }

    func deleteAll() {
        try! realm.write {
            realm.delete(realm.objects(Transaction.self))
            realm.delete(realm.objects(TransactionCategory.self))
        }
    }
}
