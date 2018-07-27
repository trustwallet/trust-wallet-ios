// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore
import PromiseKit
import BigInt
import APIKit
import JSONRPCKit

final class WalletBalanceProvider {

    let server: RPCServer
    let address: Address

    init(
        server: RPCServer,
        address: Address
        ) {
        self.server = server
        self.address = address
    }

    func balance() -> Promise<BigInt> {
        return Promise { seal in
            let request = EtherServiceRequest(for: server, batch: BatchFactory().create(BalanceRequest(address: address.description)))
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
