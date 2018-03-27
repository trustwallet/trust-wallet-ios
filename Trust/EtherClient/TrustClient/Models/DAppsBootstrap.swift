// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct DAppsBootstrap: Codable {
    let today: [DAppModel]
    let popular: [DAppModel]
    let new: [DAppModel]

    public init(today: [DAppModel] = [], popular: [DAppModel] = [], new: [DAppModel] = []) {
        self.today = today
        self.popular = popular
        self.new = new
    }
}
