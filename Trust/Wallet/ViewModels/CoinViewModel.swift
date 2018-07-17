// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore

struct CoinViewModel {

    let coin: Coin

    var name: String {
        switch coin {
        case .bitcoin: return "Bitcoin"
        case .ethereum: return "Ethereum"
        case .ethereumClassic: return "Ethereum Classic"
        case .poa: return "POA Network"
        case .callisto: return "Callisto"
        case .gochain: return "GoChain"
        }
    }
}
