// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt
@testable import Trust

extension GasViewModel {
    static func make(fee: BigInt = BigInt(100), server: RPCServer = .main, store: TokensDataStore = FakeTokensDataStore()) -> GasViewModel {
        return GasViewModel(fee: fee, server: server, store: store)
    }
}
