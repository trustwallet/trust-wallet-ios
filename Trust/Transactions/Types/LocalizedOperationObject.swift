// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift
import TrustKeystore

class LocalizedOperationObject: Object {
    @objc dynamic var from: String = ""
    @objc dynamic var to: String = ""
    @objc dynamic var contract: String? = .none
    @objc dynamic var type: String = ""
    @objc dynamic var value: String = ""
    @objc dynamic var name: String? = .none
    @objc dynamic var symbol: String? = .none
    @objc dynamic var decimals: Int = 18

    convenience init(
        from: String,
        to: String,
        contract: String?,
        type: String,
        value: String,
        symbol: String?,
        name: String?,
        decimals: Int
    ) {
        self.init()
        self.from = from
        self.to = to
        self.contract = contract
        self.type = type
        self.value = value
        self.symbol = symbol
        self.name = name
        self.decimals = decimals
    }

    var operationType: OperationType {
        return OperationType(string: type)
    }
}

extension LocalizedOperationObject {
    static func from(operations: [LocalizedOperation]?) -> [LocalizedOperationObject] {
        guard let operations = operations else { return [] }
        return operations.flatMap { operation in
            guard
                let from = Address(string: operation.from),
                let to = Address(string: operation.to) else {
                    return .none
            }
            return LocalizedOperationObject(
                from: from.description,
                to: to.description,
                contract: operation.contract.address,
                type: operation.type.rawValue,
                value: operation.value,
                symbol: operation.contract.symbol,
                name: operation.contract.name,
                decimals: operation.contract.decimals
            )
        }
    }
}
