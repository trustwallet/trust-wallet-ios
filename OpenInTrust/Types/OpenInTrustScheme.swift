// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct SchemeBuilder {
    let target: URL
    let scheme = "trust"

    func build() -> URL {
        let url = URL(string: "\(scheme)://browser?target=\(target.absoluteString)") ?? URL(string: "\(scheme)://")!
        return url
    }
}
