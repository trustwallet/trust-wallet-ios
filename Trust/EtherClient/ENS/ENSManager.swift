// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore
import RealmSwift
import PromiseKit

//struct ENSManager {
//
//    var store: ENSStore
//    let localInterval: Double = 24 * 60 * 60 // 1 day
//    let client: ENSClient
//
//    init(realm: Realm, config: Config = Config()) {
//        self.store = ENSStore(realm: realm)
//        self.client = ENSClient(server: config.server)
//    }
//
//    func resolve(name: String, ignoreCache: Bool = false) -> Promise<Address> {
//        guard client.ensAvailable else {
//            return Promise { $0.reject(ENSError.contractNotFound) }
//        }
//        let now = Date()
//        let filtered = store.records.filter("name == %@", name)
//        if ignoreCache == false, let record = filtered.first, now.timeIntervalSince(record.updatedAt) <= localInterval {
//            return Promise { $0.resolve(EthereumAddress(string: record.owner), nil) }
//        }
//        return client.resolve(name: name).map { result -> EthereumAddress in
//            if result.address != EthereumAddress.zero {
//                self.store.add(record: ENSRecord(name: name, address: result.address.description, resolver: result.resolver.description))
//            }
//            return result.address
//        }
//    }
//
//    func lookup(address: EthereumAddress, ignoreCache: Bool = false) -> Promise<String> {
//        guard client.ensAvailable else {
//            return Promise { $0.reject(ENSError.contractNotFound) }
//        }
//        let now = Date()
//        let filtered = store.records.filter("address == %@", address.description)
//        if ignoreCache == false, let record = filtered.first, now.timeIntervalSince(record.updatedAt) <= localInterval {
//            return Promise { $0.resolve(record.name, nil) }
//        }
//        return client.lookup(address: address).map { name -> String in
//            if !name.isEmpty {
//                self.store.add(record: ENSRecord(name: name, address: address.description, isReverse: true))
//            }
//            return name
//        }
//    }
//}
