// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import Geth
import Result
import KeychainSwift

class EtherKeystore: Keystore {
    
    private let keychain = KeychainSwift(keyPrefix: "trustwallet")
    let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    lazy var ks: GethKeyStore = {
        return GethNewKeyStore(self.datadir + "/keystore", GethLightScryptN, GethLightScryptP)
    }()

    init() {
        
    }
    
    var hasAccounts: Bool {
        return accounts.count > 0
    }
    
    func createAccout(password: String) -> Account {
        let account = try! ks.newAccount(password)
        return .from(account: account)
    }
    
    func importKeystore(value: String, password: String) -> Result<Account, KeyStoreError> {
        let data = value.data(using: .utf8)
        do {
            let gethAccount = try ks.importKey(data, passphrase: password, newPassphrase: password)
            let account: Account = .from(account: gethAccount)
            let _ = setPassword(password, for: account)
            return (.success(account))
        } catch {
            return (.failure(.failedToImport))
        }
    }
    
    func importPrivateKey() -> Account? {
        return nil
//        return Account(
//            address: ""
//        )
    }
    
    var accounts: [Account] {
        return self.gethAccounts.map {Account(address: Address(address: $0.getAddress().getHex()))}
    }
    
    var gethAccounts: [GethAccount] {
        var finalAccounts: [GethAccount] = []
        let allAccounts = ks.getAccounts()
        let size = allAccounts?.size() ?? 0
        
        for i in 0..<size {
            if let account = try! allAccounts?.get(i) {
                finalAccounts.append(account)
            }
        }
        
        return finalAccounts
    }
    
    func export(account: Account, password: String) -> Result<String, KeyStoreError> {
        let result = exportData(account: account, password: password)
        switch result {
        case .success(let data):
            let string = String(data: data, encoding: .utf8) ?? ""
            return (.success(string))
        case .failure(let error):
            return (.failure(error))
        }
    }
    
    func exportData(account: Account, password: String) -> Result<Data, KeyStoreError> {
        let gethAccount = getGethAccount(for: account.address)
        do {
            let data = try ks.exportKey(gethAccount, passphrase: password, newPassphrase: password)
            return (.success(data))
        } catch {
            return (.failure(.failedToDecryptKey))
        }
    }
    
    func delete(account: Account, password: String, completion: (Result<Void, KeyStoreError>) -> Void) {
        let gethAccount = getGethAccount(for: account.address)
        
        do {
            try ks.delete(gethAccount, passphrase: password)
            completion(.success())
        } catch {
            completion(.failure(.failedToDeleteAccount))
        }
    }
    
    func signTransaction(
        amount: GethBigInt,
        account: Account,
        address: Address,
        nonce: Int64,
        gasPrice: GethBigInt = GethNewBigInt(50000000000),
        gasLimit: GethBigInt = GethNewBigInt(90000),
        data: Data = Data(),
        chainID: GethBigInt = GethNewBigInt(1)
    ) -> Result<Data, KeyStoreError> {
        let gethAddress = GethNewAddressFromHex(address.address, nil)
        
        let transaction = GethNewTransaction(nonce, gethAddress, amount, gasLimit, gasPrice, data)
        let password = getPassword(for: account)
        
        let gethAccount = getGethAccount(for: address)
        
        do {
            try ks.unlock(gethAccount, passphrase: password)
            let signedTransaction = try ks.signTx(gethAccount, tx: transaction, chainID: chainID)
            NSLog("signedTransaction \(try signedTransaction.encodeJSON())")
            let rlp = try signedTransaction.encodeRLP()
            return (.success(rlp))
        } catch {
            return (.failure(.failedToSignTransaction))
        }
    }
    
    func getPassword(for account: Account) -> String? {
        return keychain.get(account.address.address)
    }
    
    func setPassword(_ password: String, for account: Account) -> Bool {
        return keychain.set(password, forKey: account.address.address)
    }
    
    func getGethAccount(for address: Address) -> GethAccount {
        return gethAccounts.filter{ $0.getAddress().getHex() == address.address }.first!
    }
}

extension Account {
    static func from(account: GethAccount) -> Account {
        return Account(
            address: Address(address: account.getAddress().getHex())
        )
    }
}
