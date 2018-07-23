// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust

extension ChainState {
    static func make(
        server: RPCServer = .make()
    ) -> ChainState {
        return ChainState(
            server: .make()
        )
    }
}
