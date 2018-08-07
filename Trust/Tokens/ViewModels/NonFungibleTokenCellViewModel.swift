// Copyright DApps Platform Inc. All rights reserved.

import UIKit

final class NonFungibleTokenCellViewModel {

    private let tokens: [CollectibleTokenObject]

    init(tokens: [CollectibleTokenObject]) {
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

    func token(for index: IndexPath) -> CollectibleTokenObject {
        return tokens[index.row]
    }
}
