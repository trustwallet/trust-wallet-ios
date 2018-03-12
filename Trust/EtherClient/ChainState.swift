// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JSONRPCKit
import APIKit

class ChainState {

    struct Keys {
        static let latestBlock = "chainID"
    }

    let config: Config

    private var latestBlockKey: String {
        return "\(config.chainID)-" + Keys.latestBlock
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
        let request = EtherServiceRequest(batch: BatchFactory().create(BlockNumberRequest()))
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

    func confirmations(fromBlock: Int) -> Int? {
        guard fromBlock > 0 else { return nil }
        let block = latestBlock - fromBlock
        guard latestBlock != 0, block > 0 else { return nil }
        return max(0, block)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
        updateLatestBlock?.invalidate()
        updateLatestBlock = nil
    }
}
