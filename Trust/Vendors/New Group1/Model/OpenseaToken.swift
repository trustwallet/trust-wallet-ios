// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct NonFungibleToken: Codable {
    let name: String
    let image_url: String
    let external_link: String
}

extension NonFungibleToken {
    var imageURL: URL? {
        return URL(string: image_url)
    }

    var externalLinkURL: URL? {
        return URL(string: external_link)
    }
}
