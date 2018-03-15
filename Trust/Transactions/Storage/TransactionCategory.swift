// Copyright SIX DAY LLC. All rights reserved.

import RealmSwift

class TransactionCategory: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var date = Date()
    var transactions = List<Transaction>()

    override static func primaryKey() -> String? {
        return "title"
    }
}
