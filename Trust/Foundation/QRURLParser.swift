// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ParserResult {
    let protocolName: String
    let address: String
    let params: [String: String]
}

struct QRURLParser {

    static func from(string: String) -> ParserResult? {
        if string.count == 42 {
            return ParserResult(
                protocolName: "",
                address: string,
                params: [:]
            )
        }

        guard string.count >= 51 else { return .none }

        return ParserResult(
            protocolName: string.substring(with: 0..<8),
            address: string.substring(with: 9..<51),
            params: [:]
        )
    }
}

extension ParserResult: Equatable {
    static func == (lhs: ParserResult, rhs: ParserResult) -> Bool {
        return lhs.protocolName == rhs.protocolName && lhs.address == rhs.address && lhs.params == rhs.params
    }
}
