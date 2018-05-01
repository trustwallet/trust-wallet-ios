// Copyright SIX DAY LLC. All rights reserved.

import UIKit

struct NonFungibleTokenCellViewModel {

    let tokens: [NonFungibleTokenObject]

    init(tokens: [NonFungibleTokenObject]) {
        self.tokens = tokens
    }

    /*
    var imagePath: URL? {
        return URL(string: token.imagePath)
    }
    */

    lazy var numberOfItemsInSection: Int = {
        return tokens.count
    }()

}
