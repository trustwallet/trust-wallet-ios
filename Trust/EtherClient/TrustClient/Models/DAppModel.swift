// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct DAppModel: Codable {
    let name: String
    let image: String
    let url: String

    var imageURL: URL? {
        return URL(string: image)
    }

    var linkURL: URL? {
        return URL(string: url)
    }
}
