// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

public struct GasLimitConfiguration {
    static let `default` = BigInt(90_000)
    static let min = BigInt(21_000)
    static let max = BigInt(600_000)
}
