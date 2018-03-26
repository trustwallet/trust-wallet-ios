// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct DAppModel: Codable {
    let name: String
    let image: String

    var imageURL: URL? {
        return URL(string: image)
    }
}
