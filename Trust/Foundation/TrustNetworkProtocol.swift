// Copyright DApps Platform Inc. All rights reserved.

import Moya
import TrustCore

protocol TrustNetworkProtocol {
    var provider: MoyaProvider<TrustAPI> { get }
}
