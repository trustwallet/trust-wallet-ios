// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct TokenViewModel {

    let type: TokenType
    let config: Config

    init(
        type: TokenType,
        config: Config = Config()
    ) {
        self.type = type
        self.config = config
    }

    var title: String {
        switch type {
        case .ether:
            return config.server.displayName
        case .token(let token):
            return token.name
        }
    }
}
