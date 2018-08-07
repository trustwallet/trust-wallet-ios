// Copyright DApps Platform Inc. All rights reserved.

import UIKit

struct NonFungibleCollectionViewCellModel {

    let token: CollectibleTokenObject

    init(token: CollectibleTokenObject) {
        self.token = token
    }

    var name: String {
        return token.name
    }

    var annotation: String {
        return token.annotation
    }

    var imagePath: URL? {
        return token.imageURL
    }
}
