// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import Result

struct FakeKeystore: Keystore {
    static var current: Account?
    var hasAccounts: Bool {
        return accounts.count > 0
    }
    var accounts: [Account]
    var recentlyUsedAccount: Account?

    init(
        accounts: [Account] = [],
        recentlyUsedAccount: Account? = .none
    ) {
        self.accounts = accounts
        self.recentlyUsedAccount = recentlyUsedAccount
    }

    func createAccount(with password: String, completion: @escaping (Result<Account, KeystoreError>) -> Void) {
        completion(.success(.make()))
    }

    func importWallet(type: ImportType, completion: @escaping (Result<Account, KeystoreError>) -> Void) {
        //TODO: Implement
    }

    func keystore(for privateKey: String, password: String, completion: @escaping (Result<String, KeystoreError>) -> Void) {
        //TODO: Implement
    }

    func importKeystore(value: String, password: String, completion: @escaping (Result<Account, KeystoreError>) -> Void) {
        //TODO: Implement
    }

    func createAccout(password: String) -> Account {
        //TODO: Implement
        return Account(address: .make())
    }

    func importKeystore(value: String, password: String) -> Result<Account, KeystoreError> {
        //TODO: Implement
        return .failure(KeystoreError.failedToSignTransaction)
    }

    func export(account: Account, password: String, newPassword: String) -> Result<String, KeystoreError> {
        //TODO: Implement
        return .failure(KeystoreError.failedToSignTransaction)
    }

    func exportData(account: Account, password: String, newPassword: String) -> Result<Data, KeystoreError> {
        //TODO: Implement
        return .failure(KeystoreError.failedToSignTransaction)
    }

    func delete(account: Account) -> Result<Void, KeystoreError> {
        //TODO: Implement
        return .failure(KeystoreError.failedToSignTransaction)
    }

    func updateAccount(account: Account, password: String, newPassword: String) -> Result<Void, KeystoreError> {
        //TODO: Implement
        return .failure(KeystoreError.failedToSignTransaction)
    }

    func signTransaction(_ signTransaction: SignTransaction) -> Result<Data, KeystoreError> {
        //TODO: Implement
        return .failure(KeystoreError.failedToSignTransaction)
    }

    func getPassword(for account: Account) -> String? {
        //TODO: Implement
        return .none
    }

    func convertPrivateKeyToKeystoreFile(privateKey: String, passphrase: String) -> Result<[String : Any], KeystoreError> {
        //TODO: Implement
        return .failure(KeystoreError.failedToSignTransaction)
    }
}

extension FakeKeystore {
    static func make(
        accounts: [Account] = [],
        recentlyUsedAccount: Account? = .none
    ) -> FakeKeystore {
        return FakeKeystore(
            accounts: accounts,
            recentlyUsedAccount: recentlyUsedAccount
        )
    }
}
