// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Result

struct OnePasswordConverter {

    static let divider = "-divider-"

    static func toPassword(password: String, keystore: String) -> String {
        return password + divider + keystore
    }

    static func fromPassword(password: String) -> Result<(password: String, keystore: String), OnePasswordError> {
        let split = password.components(separatedBy: divider)
        if split.count >= 2 {
            return .success((password: split[0], keystore: split[1]))
        }
        return .failure(OnePasswordError.wrongFormat)
    }
}
