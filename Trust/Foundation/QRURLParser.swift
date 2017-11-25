// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ParserResult {
    let protocolName: String
    let address: String
    let params: [String: String]
}

struct QRURLParser {

    static func from(string: String) -> ParserResult? {
        let parts = string.components(separatedBy: ":")
        if parts.count == 1, let address = parts.first, CryptoAddressValidator.isValidAddress(address) {
            return ParserResult(
                protocolName: "",
                address: address,
                params: [:]
            )
        }

        if parts.count == 2, let address = parts.last, CryptoAddressValidator.isValidAddress(address) {
            return ParserResult(
                protocolName: parts.first ?? "",
                address: address,
                params: [:]
            )
        }

        return nil
    }
}

extension ParserResult: Equatable {
    static func == (lhs: ParserResult, rhs: ParserResult) -> Bool {
        return lhs.protocolName == rhs.protocolName && lhs.address == rhs.address && lhs.params == rhs.params
    }
}
