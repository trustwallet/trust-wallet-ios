// Copyright DApps Platform Inc. All rights reserved.

//https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md
import Foundation
import TrustCore

struct EIP712Type: Codable {
    let name: String
    let type: String
}

struct EIP712Domain: Codable {
    let name: String
    let version: String
    let chainId: Int
    let verifyingContract: String
}

struct EIP712TypedData: Codable {
    let types: [String: [EIP712Type]]
    let primaryType: String
    let domain: JSON
    let message: JSON
}

extension EIP712TypedData {
    func findDependencies(primaryType: String, dependencies: Set<String> = Set<String>()) -> Set<String> {
        var found = dependencies
        guard !found.contains(primaryType),
            let primaryTypes = types[primaryType] else {
                return found
        }
        found.insert(primaryType)
        for type in primaryTypes {
            findDependencies(primaryType: type.type, dependencies: found)
                .forEach { found.insert($0) }
        }
        return found
    }

    func encodeType(primaryType: String) -> Data {
        var depSet = findDependencies(primaryType: primaryType)
        depSet.remove(primaryType)
        let sorted = [primaryType] + Array(depSet).sorted()
        let encoded = sorted.map { type in
            let param = types[type]!.map { "\($0.type) \($0.name)" }.joined(separator: ",")
            return "\(type)(\(param))"
        }.joined()
        return encoded.data(using: .utf8) ?? Data()
    }

    func encodeData(data: JSON, type: String) -> Data {
        let encoder = ABIEncoder()
        var values: [ABIValue] = []
        do {
            let typeHash = Crypto.hash(encodeType(primaryType: type))
            let typeHashValue = try ABIValue(typeHash, type: .bytes(32))
            values.append(typeHashValue)
            if let valueTypes = types[type] {
                try valueTypes.forEach { field in
                    if let _ = types[field.type],
                        let json = data[field.name] {
                        let nestEncoded = encodeData(data: json, type: field.type)
                        values.append(try ABIValue(Crypto.hash(nestEncoded), type: .bytes(32)))
                    } else if let value = makeABIValue(data: data[field.name], type: field.type) {
                        values.append(value)
                    }
                }
            }
            try encoder.encode(tuple: values)
        } catch let error {
            print(error)
        }
        return encoder.data
    }

    private func makeABIValue(data: JSON?, type: String) -> ABIValue? {
        if (type == "string" || type == "bytes"),
            let value = data?.stringValue,
            let valueData = value.data(using: .utf8) {
            return try? ABIValue(Crypto.hash(valueData), type: .bytes(32))
        } else if type == "bool",
            let value = data?.boolValue {
            return try? ABIValue(value, type: .bool)
        } else if type == "address",
            let value = data?.stringValue,
            let address = EthereumAddress(string: value) {
            return try? ABIValue(address, type: .address)
        } else if type.starts(with: "uint") {
            let size = parseIntSize(type: type, prefix: "uint")
            if size > 0, let value = data?.floatValue {
                return try? ABIValue(Int(value), type: .uint(bits: size))
            }
        } else if type.starts(with: "int") {
            let size = parseIntSize(type: type, prefix: "int")
            if size > 0, let value = data?.floatValue {
                return try? ABIValue(Int(value), type: .int(bits: size))
            }
        } else if type.starts(with: "bytes") {
            if let length = Int(type.dropFirst("bytes".count)),
                let value = data?.stringValue {
                return try? ABIValue(value.isHexEncoded ? Data(hex: value) : Data(bytes: Array(value.utf8)), type: .bytes(length))
            }
        }
        //TODO array types
        return nil
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
}
