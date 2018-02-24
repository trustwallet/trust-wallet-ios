// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum BalanceStatus {
    case ether(etherSufficient: Bool, gasSufficient: Bool)
    case token(tokenSufficient: Bool, gasSufficient: Bool)
}

extension BalanceStatus {

    enum Key {
        case insufficientEther
        case insufficientGas
        case insufficientToken
        case none

        var string: String {
            switch self {
            case .insufficientEther:
                return "send.error.insufficientEther"
            case .insufficientGas:
                return "send.error.insufficientGas"
            case .insufficientToken:
                return "send.error.insufficientToken"
            case .none:
                return ""
            }
        }
    }

    private func _L(_ key: String, value: String? = .none) -> String {
        return NSLocalizedString(key, value: value ?? key, comment: "")
    }

    var sufficient: Bool {
        switch self {
        case .ether(let etherSufficient, let gasSufficient):
            return etherSufficient && gasSufficient
        case .token(let tokenSufficient, let gasSufficient):
            return tokenSufficient && gasSufficient
        }
    }

    var insufficientTextKey: Key {
        switch self {
        case .ether(let etherSufficient, let gasSufficient):
            if !etherSufficient {
                return .insufficientEther
            }
            if !gasSufficient {
                return .insufficientGas
            }
        case .token(let tokenSufficient, let gasSufficient):
            if !tokenSufficient {
                return .insufficientToken
            }
            if !gasSufficient {
                return .insufficientGas
            }
        }
        return .none
    }

    var insufficientText: String {
        let key = insufficientTextKey
        if key == Key.insufficientEther {
            return _L(key.string, value: "Insufficient ethers")
        } else if key == Key.insufficientGas {
            return _L(key.string, value: "Insufficient ethers for gas fee")
        } else if key == Key.insufficientToken {
            return _L(key.string, value: "Insufficient tokens")
        }
        return ""
    }
}
