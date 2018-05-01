// Copyright SIX DAY LLC. All rights reserved.

import UIKit

struct NonFungibleTokenCellViewModel {

    private let tokens: [NonFungibleTokenObject]

    init(tokens: [NonFungibleTokenObject]) {
        self.tokens = tokens
    }

    lazy var numberOfItemsInSection: Int = {
        return tokens.count
    }()

    func collectionViewModel(for index: IndexPath) -> NonFungibleCollectionViewCellModel {
        return NonFungibleCollectionViewCellModel(token: tokens[index.row])
    }

    func token(for index: IndexPath) -> NonFungibleTokenObject {
        return tokens[index.row]
    }
}
