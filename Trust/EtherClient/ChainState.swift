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

    let config: Config

    private var latestBlockKey: String {
        return "\(config.chainID)-" + Keys.latestBlock
    }

    private var gasPriceBlockKey: String {
        return "\(config.chainID)-" + Keys.gasPrice
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
        config: Config = Config()
    ) {
        self.config = config
        self.defaults = config.defaults
        NotificationCenter.default.addObserver(self, selector: #selector(ChainState.stopTimers), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChainState.restartTimers), name: .UIApplicationDidBecomeActive, object: nil)
        runScheduledTimers()
    }
    func start() {
        fetch()
    }

    func stop() {
        updateLatestBlock?.invalidate()
        updateLatestBlock = nil
    }
    @objc func stopTimers() {
        updateLatestBlock?.invalidate()
        updateLatestBlock = nil
    }
    @objc func restartTimers() {
        runScheduledTimers()
    }
    private func runScheduledTimers() {
        guard updateLatestBlock == nil else {
            return
        }
        self.updateLatestBlock = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(fetch), userInfo: nil, repeats: true)
    }

    @objc func fetch() {
        getLastBlock()
        getGasPrice()
    }

    private func getLastBlock() {
        let request = EtherServiceRequest(batch: BatchFactory().create(BlockNumberRequest()), timeoutInterval: 5.0)
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
        let request = EtherServiceRequest(batch: BatchFactory().create(GasPriceRequest()))
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
    deinit {
        NotificationCenter.default.removeObserver(self)
        updateLatestBlock?.invalidate()
        updateLatestBlock = nil
    }
}
