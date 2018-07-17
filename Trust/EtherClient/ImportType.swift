// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore

enum ImportType {
    case keystore(string: String, password: String)
    case privateKey(privateKey: String)
    case mnemonic(words: [String], password: String, derivationPath: DerivationPath)
    case address(address: EthereumAddress)
}
