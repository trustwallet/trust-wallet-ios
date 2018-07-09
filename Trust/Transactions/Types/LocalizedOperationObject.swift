// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import RealmSwift
import TrustCore

final class LocalizedOperationObject: Object, Decodable {
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

    enum LocalizedOperationObjectKeys: String, CodingKey {
        case from
        case to
        case type
        case value
        case contract
    }

    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: LocalizedOperationObjectKeys.self)
        let from = try container.decode(String.self, forKey: .from)
        let to = try container.decode(String.self, forKey: .to)

        guard
            let fromAddress = Address(string: from),
            let toAddress = Address(string: to) else {
                let context = DecodingError.Context(codingPath: [LocalizedOperationObjectKeys.from,
                                                                 LocalizedOperationObjectKeys.to, ],
                                                    debugDescription: "Address can't be decoded as a TrustKeystore.Address")
                throw DecodingError.dataCorrupted(context)
        }
        let type = try container.decode(OperationType.self, forKey: .type)
        let value = try container.decode(String.self, forKey: .value)
        let contract = try container.decode(ERC20Contract.self, forKey: .contract)

        self.init(from: fromAddress.description,
                  to: toAddress.description,
                  contract: contract.address,
                  type: type.rawValue,
                  value: value,
                  symbol: contract.symbol,
                  name: contract.name,
                  decimals: contract.decimals
        )
    }

    var operationType: OperationType {
        return OperationType(string: type)
    }
}
