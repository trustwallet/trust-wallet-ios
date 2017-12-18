// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class LocalizedOperationObject: Object {
    @objc dynamic var from: String = ""
    @objc dynamic var to: String = ""
    @objc dynamic var contract: String? = .none
    @objc dynamic var type: String = ""
    @objc dynamic var value: String = ""
    @objc dynamic var symbol: String? = .none
    @objc dynamic var decimals: Int = 18

    convenience init(
        from: String,
        to: String,
        contract: String?,
        type: String,
        value: String,
        symbol: String?,
        decimals: Int
    ) {
        self.init()
        self.from = from
        self.to = to
        self.contract = contract
        self.type = type
        self.value = value
        self.symbol = symbol
        self.decimals = decimals
    }

    var operationType: OperationType {
        return OperationType(string: type)
    }
}

extension LocalizedOperationObject {
    static func from(operations: [LocalizedOperation]?) -> [LocalizedOperationObject] {
        guard let operations = operations else { return [] }
        return operations.map { operation in
            return LocalizedOperationObject(
                from: operation.from,
                to: operation.to,
                contract: operation.contract.address,
                type: operation.type.rawValue,
                value: operation.value,
                symbol: operation.contract.symbol,
                decimals: operation.contract.decimals
            )
        }
    }
}
