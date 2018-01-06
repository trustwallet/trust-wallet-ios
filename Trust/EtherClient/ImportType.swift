// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum ImportType {
    case keystore(string: String, password: String)
    case privateKey(privateKey: String)
    case watch(address: Address)
}
