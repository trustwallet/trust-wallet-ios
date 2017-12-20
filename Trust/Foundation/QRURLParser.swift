// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ParserResult {
    let protocolName: String
    let address: String
    let params: [String: String]
}

func parseParamsFromParamParts(paramParts: [String]) -> [String: String] {
    if paramParts.isEmpty {
        return [:]
    }
    var params = [String: String]()
    var i = 0
    while i < paramParts.count {
        let tokenizedParamParts = paramParts[i].components(separatedBy: "=")
        if tokenizedParamParts.count < 2 {
            return [:]
        }
        params[tokenizedParamParts[0]] = params[tokenizedParamParts[1]]
        i += 1
    }
    return params
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

        if parts.count == 2, let address = QRURLParser.getAddress(from: parts.last), CryptoAddressValidator.isValidAddress(address) {
            let paramParts = parts[1].components(separatedBy: "?")
            let params = parseParamsFromParamParts(paramParts: paramParts)
            return ParserResult(
                protocolName: parts.first ?? "",
                address: address,
                params: params
            )
        }

        return nil
    }

    private static func getAddress(from: String?) -> String? {
        guard let from = from, from.count >= AddressValidatorType.ethereum.addressLength else {
            return .none
        }
        return from.substring(to: AddressValidatorType.ethereum.addressLength)
    }
}

extension ParserResult: Equatable {
    static func == (lhs: ParserResult, rhs: ParserResult) -> Bool {
        return lhs.protocolName == rhs.protocolName && lhs.address == rhs.address && lhs.params == rhs.params
    }
}
