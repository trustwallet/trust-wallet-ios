// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct MarketplaceItemViewModel {

    let item: MarketplaceItem

    init(item: MarketplaceItem) {
        self.item = item
    }

    var name: String {
        return item.name
    }

    var description: String {
        return item.description
    }

    var imageURL: URL? {
        return URL(string: item.image ?? "")
    }

    var url: URL {
        return URL(string: item.url)!
    }

    var placeholderImage: UIImage? {
        return .none
    }
}
