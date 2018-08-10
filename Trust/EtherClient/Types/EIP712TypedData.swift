// Copyright DApps Platform Inc. All rights reserved.

import Foundation

struct EIP712Type: Decodable {
    let name: String
    let type: String
}

struct EIP712Domain: Decodable {
    let name: String
    let version: String
    let chainId: Int
    let verifyingContract: String
}

struct EIP712TypedData: Decodable {
    let types: [String: [EIP712Type]]
    let primaryType: String
    let domain: EIP712Domain
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

    func encodeType(primaryType: String) -> String {
        var depSet = findDependencies(primaryType: primaryType)
        depSet.remove(primaryType)
        let sorted = [primaryType] + Array(depSet).sorted()
        return sorted.map { type in
            let param = types[type]!.map { "\($0.type) \($0.name)" }.joined(separator: ",")
            return "\(type)(\(param))"
        }.joined()
    }
}
