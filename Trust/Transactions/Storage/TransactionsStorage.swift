// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift
import TrustKeystore

class TransactionsStorage {

    let realm: Realm

    var transactions: Results<Transaction> {
        return realm.objects(Transaction.self).sorted(byKeyPath: "date", ascending: false)
    }

    var transactionsCategory: Results<TransactionCategory> {
        return realm.objects(TransactionCategory.self)
    }

    init(
        realm: Realm
    ) {
        self.realm = realm
    }

    var count: Int {
        return objects.count
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
        realm.beginWrite()
        realm.add(trnasactions, update: true)
        try! realm.commitWrite()

        // store contract addresses associated with transactions
        let tokens = self.tokens(from: items)
        if !tokens.isEmpty {
            TokensDataStore.update(in: realm, tokens: tokens)
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
            guard let date = $0 as? String else {
                return
            }
            let filteredTransactionByDate = transactions.filter { TransactionsViewModel.realmBaseFormmater.string(from: $0.date ) == date }
            let item = TransactionCategory()
            item.title = date
            item.transactions.append(objectsIn: filteredTransactionByDate)
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
        realm.beginWrite()
        transaction.internalState = state.rawValue
        try! realm.commitWrite()
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
        }
    }
}
