// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore
import PromiseKit
import BigInt
import APIKit
import JSONRPCKit

final class CoinNetworkProvider: BalanceNetworkProvider {
    let server: RPCServer
    let addressUpdate: Address

    init(
        server: RPCServer,
        addressUpdate: Address
    ) {
        self.server = server
        self.addressUpdate = addressUpdate
    }

    func balance() -> Promise<BigInt> {
        return Promise { seal in
            let request = EtherServiceRequest(for: server, batch: BatchFactory().create(BalanceRequest(address: addressUpdate.description)))
            Session.send(request) { result in
                switch result {
                case .success(let balance):
                    seal.fulfill(balance.value)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}
