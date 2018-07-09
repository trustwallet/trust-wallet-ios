// Copyright DApps Platform Inc. All rights reserved.

import UIKit

final class NonFungibleTokenCellViewModel {

    private let tokens: [NonFungibleTokenObject]

    init(tokens: [NonFungibleTokenObject]) {
        self.tokens = tokens
    }

    lazy var collectionViewBacgroundColor: UIColor = {
        return UIColor.white
    }()

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
