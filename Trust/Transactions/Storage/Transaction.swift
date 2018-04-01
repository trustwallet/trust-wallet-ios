// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift
import TrustKeystore

class Transaction: Object, Decodable {
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

    private enum TransactionCodingKeys: String, CodingKey {
        case id = "_id"
        case blockNumber
        case from
        case to
        case value
        case gas
        case gasPrice
        case gasUsed
        case nonce // Here we need to convert (from Int)]
        case timeStamp // Convert from timestamp
        case operations // Operations needs custom decoding
        case error // Only to throw
    }

    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TransactionCodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let blockNumber = try container.decode(Int.self, forKey: .blockNumber)
        let from = try container.decode(String.self, forKey: .from)
        let to = try container.decode(String.self, forKey: .to)
        let value = try container.decode(String.self, forKey: .value)
        let gas = try container.decode(String.self, forKey: .gas)
        let gasPrice = try container.decode(String.self, forKey: .gasPrice)
        let gasUsed = try container.decode(String.self, forKey: .gasUsed)
        let rawNonce = try container.decode(Int.self, forKey: .nonce)
        let timeStamp = try container.decode(String.self, forKey: .timeStamp)
        let error = try container.decodeIfPresent(String.self, forKey: .error)
        let operations = try container.decode([LocalizedOperationObject].self, forKey: .operations)

        guard
            let fromAddress = Address(string: from) else {
                let context = DecodingError.Context(codingPath: [TransactionCodingKeys.from],
                                                    debugDescription: "Address can't be decoded as a TrustKeystore.Address")
                throw DecodingError.dataCorrupted(context)
        }

        let state: TransactionState = {
            if error?.isEmpty == false {
                return .error
            }
            return .completed
        }()

        self.init(id: id,
                  blockNumber: blockNumber,
                  from: fromAddress.description,
                  to: to,
                  value: value,
                  gas: gas,
                  gasPrice: gasPrice,
                  gasUsed: gasUsed,
                  nonce: String(rawNonce),
                  date: Date(timeIntervalSince1970: TimeInterval(timeStamp) ?? 0),
                  localizedOperations: operations,
                  state: state)
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
        return "nonce"
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
