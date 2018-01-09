// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore

enum ImportType {
    case keystore(string: String, password: String)
    case privateKey(privateKey: String)
    case mnemonic(words: [String])
    case watch(address: Address)
}
