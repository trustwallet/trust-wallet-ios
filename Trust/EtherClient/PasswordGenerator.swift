// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Security

struct PasswordGenerator {

    static func generateRandom() -> String {
        return NSUUID().uuidString + PasswordGenerator.generateRandomString(bytesCount: 16)
    }

    static func generateRandomString(bytesCount: Int) -> String {
        var randomBytes = [UInt8](repeating: 0, count: bytesCount)
        let _ = SecRandomCopyBytes(kSecRandomDefault, bytesCount, &randomBytes)
        return randomBytes.map({ String(format: "%02hhx", $0) }).joined(separator: "")
    }
}
