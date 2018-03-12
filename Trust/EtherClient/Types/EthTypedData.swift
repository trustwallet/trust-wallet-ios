// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct EthTypedData: Codable {
    //for signTypedMessage
    let type: String
    let name: String
    let value: String

    var schemaString: String {
        return "\(type) \(name)"
    }

    var schemaData: Data {
        return Data(bytes: Array(schemaString.utf8))
    }

    var typedData: Data {
        if type == "bytes" {
            return Data(bytes: Array(value.utf8))
        } else if type == "string" {
            return Data(bytes: Array(value.utf8))
        }
        //FIXME handle other types
        return Data()
    }
}
