// Copyright SIX DAY LLC. All rights reserved.

import UIKit

struct NonFungibleTokenCellViewModel {
    let token: NonFungibleTokenObject
    init(token: NonFungibleTokenObject) {
        self.token = token
    }
    var name: String {
        return token.name
    }
    var annotation: String {
        return token.annotation
    }
    var imagePath: URL? {
        return URL(string: token.imagePath)
    }
}
