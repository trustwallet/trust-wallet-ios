// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct PasswordGenerator {

    static func generateRandom() -> String {
        return NSUUID().uuidString
    }
}
