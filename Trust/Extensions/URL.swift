// Copyright SIX DAY LLC. All rights reserved.

import UIKit

extension URL {

    private static var openseaPath: String {
        switch Config().server {
        case .rinkeby:
            return "https://rinkeby.opensea.io"
        default:
            return Constants.dappsOpenSea
        }
    }

    static func opensea() -> URL? {
        return URL(string: openseaPath)
    }

    static func opensea(with contract: String, and id: String) -> URL? {
        return URL(string: (openseaPath + "/assets/\(contract)/\(id)"))
    }
}
