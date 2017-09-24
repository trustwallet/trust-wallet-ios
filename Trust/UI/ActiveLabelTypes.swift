// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import ActiveLabel

extension ActiveType {

    static func ethereumAddress() -> ActiveType {
        return ActiveType.custom(pattern: "^0x")
    }
}
