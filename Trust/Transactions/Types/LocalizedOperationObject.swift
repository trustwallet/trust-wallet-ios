// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class LocalizedOperationObject: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var from: String = ""
    @objc dynamic var to: String = ""
    @objc dynamic var contract: String? = .none
    @objc dynamic var type: String = ""
    @objc dynamic var value: String = ""
    @objc dynamic var symbol: String? = .none
    @objc dynamic var decimals: String? = .none

    convenience init(
        title: String,
        from: String,
        to: String,
        contract: String?,
        type: String,
        value: String,
        symbol: String?,
        decimals: String?
    ) {
        self.init()
        self.title = title
        self.from = from
        self.to = to
        self.contract = contract
        self.type = type
        self.value = value
        self.symbol = symbol
        self.decimals = decimals
    }
}

extension LocalizedOperationObject {
    static func from(operations: [LocalizedOperation]?) -> [LocalizedOperationObject] {
        guard let operations = operations else { return [] }
        return operations.map { operation in
            return LocalizedOperationObject(
                title: operation.title,
                from: operation.from,
                to: operation.to,
                contract: operation.contract,
                type: operation.type.rawValue,
                value: operation.value,
                symbol: operation.symbol,
                decimals: operation.decimals
            )
        }
    }
}
