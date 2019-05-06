// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import IPOS

extension Config {
    static func make(
        defaults: UserDefaults = .test
    ) -> Config {
        return Config(
            defaults: defaults
        )
    }
}
