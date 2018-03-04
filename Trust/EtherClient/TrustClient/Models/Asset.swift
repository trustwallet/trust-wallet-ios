// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct Asset: Codable {
    let name: String
    let description: String
    let image_url: String
    let external_link: String

}

struct AssetCategory: Codable {
    let name: String
    let items: [Asset]
}
