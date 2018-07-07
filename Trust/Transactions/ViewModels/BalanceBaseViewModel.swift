// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

protocol BalanceBaseViewModel {
    var currencyAmount: String? { get }
    var amountFull: String { get }
    var amountShort: String { get }
    var symbol: String { get }
}
