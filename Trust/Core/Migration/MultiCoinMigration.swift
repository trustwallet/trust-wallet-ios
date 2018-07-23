// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore
import TrustKeystore
import KeychainSwift

class MultiCoinMigration {

    struct Keys {
        static let watchAddresses = "watchAddresses"
    }

    let keystore: Keystore
    let appTracker: AppTracker
    let keychain = KeychainSwift(keyPrefix: Constants.keychainKeyPrefix)

    // Deprecated
    private var watchAddresses: [String] {
        set {
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
            return UserDefaults.standard.set(data, forKey: Keys.watchAddresses)
        }
        get {
            guard let data = UserDefaults.standard.data(forKey: Keys.watchAddresses) else { return [] }
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? [String] ?? []
        }
    }

    init(
        keystore: Keystore,
        appTracker: AppTracker
    ) {
        self.keystore = keystore
        self.appTracker = appTracker
    }

    func start() -> Bool {
        if !keystore.wallets.isEmpty, appTracker.completeMultiCoinMigration == false {
            return self.runMigrate()
        }
        appTracker.completeMultiCoinMigration = true
        return false
    }

    //TODO: Just run this once
    @discardableResult func runMigrate() -> Bool {
        func keychainOldKey(for account: Account) -> String {
            guard let wallet = account.wallet else {
                return account.address.description.lowercased()
            }
            switch wallet.type {
            case .encryptedKey:
                return account.address.description.lowercased()
            case .hierarchicalDeterministicWallet:
                return "hd-wallet-" + account.address.description
            }
        }
        keystore.wallets.filter { !$0.accounts.isEmpty }.forEach { wallet in
            if let account = wallet.accounts.first, let password = keychain.get(keychainOldKey(for: account)), let wallet = wallet.currentWallet {
                let _ = keystore.setPassword(password, for: wallet)
            }
        }

        // Move string addresses to WalletAddress
        let addresses = watchAddresses.compactMap {
            EthereumAddress(string: $0)
        }.compactMap {
            WalletAddress(coin: .ethereum, address: $0)
        }
        keystore.storage.store(address: addresses)
        return true
    }
}
