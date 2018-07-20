// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import JSONRPCKit
import APIKit
import BigInt

final class ChainState {

    struct Keys {
        static let latestBlock = "chainID"
        static let gasPrice = "gasPrice"
    }

    let server: RPCServer

    private var latestBlockKey: String {
        return "\(server.chainID)-" + Keys.latestBlock
    }

    private var gasPriceBlockKey: String {
        return "\(server.chainID)-" + Keys.gasPrice
    }

    var chainStateCompletion: ((Bool, Int) -> Void)?

    var latestBlock: Int {
        get {
            return defaults.integer(forKey: latestBlockKey)
        }
        set {
            defaults.set(newValue, forKey: latestBlockKey)
        }
    }
    var gasPrice: BigInt? {
        get {
            guard let value = defaults.string(forKey: gasPriceBlockKey) else { return .none }
            return BigInt(value, radix: 10)
        }
        set { defaults.set(newValue?.description, forKey: gasPriceBlockKey) }
    }

    let defaults: UserDefaults

    var updateLatestBlock: Timer?

    init(
        server: RPCServer
    ) {
        self.server = server
        self.defaults = Config.current.defaults
        fetch()
    }

    func start() {
        fetch()
    }

    @objc func fetch() {
        getLastBlock()
        getGasPrice()
    }

    private func getLastBlock() {
        let request = EtherServiceRequest(for: server, batch: BatchFactory().create(BlockNumberRequest()), timeoutInterval: 5.0)
        Session.send(request) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let number):
                self.latestBlock = number
                self.chainStateCompletion?(true, number)
            case .failure:
                self.chainStateCompletion?(false, 0)
            }
        }
    }

    private func getGasPrice() {
        let request = EtherServiceRequest(for: server, batch: BatchFactory().create(GasPriceRequest()))
        Session.send(request) { [weak self] result in
            switch result {
            case .success(let balance):
                self?.gasPrice = BigInt(balance.drop0x, radix: 16)
            case .failure: break
            }
        }
    }

    func confirmations(fromBlock: Int) -> Int? {
        guard fromBlock > 0 else { return nil }
        let block = latestBlock - fromBlock
        guard latestBlock != 0, block >= 0 else { return nil }
        return max(1, block)
    }
}
