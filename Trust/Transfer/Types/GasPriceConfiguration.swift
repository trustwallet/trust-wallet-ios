// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

public struct GasPriceConfiguration {
    static let `default`: BigInt = EtherNumberFormatter.full.number(from: "24", units: UnitConfiguration.gasPriceUnit)!
    static let min: BigInt = EtherNumberFormatter.full.number(from: "1", units: UnitConfiguration.gasPriceUnit)!
    static let max: BigInt = EtherNumberFormatter.full.number(from: "120", units: UnitConfiguration.gasPriceUnit)!
}
