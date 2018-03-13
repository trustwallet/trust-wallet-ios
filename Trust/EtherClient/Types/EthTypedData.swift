// Copyright SIX DAY LLC. All rights reserved.

import Foundation

/*
This enum is only used to support decode solidity types (represented by json values) to swift primitive types.
 */
enum SolidityJSONValue: Decodable {
    case none
    case bool(value: Bool)
    case string(value: String)
    case address(value: String)

    // we store number in 64 bit integers
    case int(value: Int64)
    case uint(value: UInt64)

    var string: String {
        switch self {
        case .none:
            return ""
        case .bool(let bool):
            return bool ? "true" : "false"
        case .string(let string):
            return string
        case .address(let address):
            return address
        case .uint(let uint):
            return String(uint)
        case .int(let int):
            return String(int)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let boolValue = try? container.decode(Bool.self) {
            self = .bool(value: boolValue)
        } else if let uint = try? container.decode(UInt64.self) {
            self = .uint(value: uint)
        } else if let int = try? container.decode(Int64.self) {
            self = .int(value: int)
        } else if let string = try? container.decode(String.self) {
            if CryptoAddressValidator.isValidAddress(string) {
                self = .address(value: string)
            } else {
                self = .string(value: string)
            }
        } else {
            self = .none
        }
    }
}

struct EthTypedData: Decodable {
    //for signTypedMessage
    let type: String
    let name: String
    let value: SolidityJSONValue

    var schemaString: String {
        return "\(type) \(name)"
    }

    var schemaData: Data {
        return Data(bytes: Array(schemaString.utf8))
    }

    var typedData: Data {
        switch value {
        case .bool(let bool):
            let byte: UInt8 = bool ? 0x01 : 0x00
            return Data(bytes: [byte])
        case .address(let address):
            let data = Data(hex: String(address.dropFirst(2)))
            return data
        case .uint(let uint):
            let size = parseIntSize(type: type, prefix: "uint")
            guard size > 0 else { return Data() }
            return getTypedData(for: uint, align: size)
        case .int(let int):
            let size = parseIntSize(type: type, prefix: "int")
            guard size > 0 else { return Data() }
            return getTypedData(for: int, align: size)
        case .string(let string):
            if type.starts(with: "bytes") {
                return Data(hex: string)
            } else if type.starts(with: "uint") {
                let size = parseIntSize(type: type, prefix: "uint")
                guard size > 0 else { return Data() }
                if let uint = UInt64(string) {
                    return getTypedData(for: uint, align: size)
                } else {
                    //TODO larger than UInt64, we may need BigInt
                }
            } else if type.starts(with: "int") {
                let size = parseIntSize(type: type, prefix: "int")
                guard size > 0 else { return Data() }
                if let int = Int64(string) {
                    return getTypedData(for: int, align: size)
                } else {
                    //TODO larger than Int64, we may need BigInt
                }
            }
            return Data(bytes: Array(string.utf8))
        case .none:
            return Data()
        }
    }
}

private func getTypedData<T: FixedWidthInteger>(for int: T, align size: Int) -> Data {
    // assume int is UInt64 or Int64
    var intValue = int.bigEndian
    var data = Data(buffer: UnsafeBufferPointer(start: &intValue, count: 1))
    let num = size / 8 - 8
    if num > 0 {
        data.insert(contentsOf: [UInt8].init(repeating: 0, count: num), at: 0)
    } else if num < 0 {
        data = data.advanced(by: abs(num))
    }
    return data
}

private func parseIntSize(type: String, prefix: String) -> Int {
    guard type.starts(with: prefix) else {
        return -1
    }
    guard let size = Int(type.dropFirst(prefix.count)) else {
        if type == prefix {
            return 256
        }
        return -1
    }

    if size < 8 || size > 256 || size % 8 != 0 {
        return -1
    }
    return size
}
