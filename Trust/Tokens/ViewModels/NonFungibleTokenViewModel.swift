// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct NonFungibleTokenViewModel {

    let token: NonFungibleToken

    init(token: NonFungibleToken) {
        self.token = token
    }

    var name: String {
        return token.name
    }

    var imageURL: URL? {
        return token.imageURL
    }
}
