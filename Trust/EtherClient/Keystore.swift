// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation

protocol Keystore {
    var hasAccounts: Bool { get }
    var accounts: [Account] { get }
}
