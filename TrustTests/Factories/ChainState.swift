// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust

extension ChainState {
    static func make(
        config: Config = .make()
    ) -> ChainState {
        return ChainState(
            config: config
        )
    }
}
