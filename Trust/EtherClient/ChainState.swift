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
        self.updateLatestBlock = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(fetch), userInfo: nil, repeats: true)
    }

    func start() {
        fetch()
    }

    func stop() {
        updateLatestBlock?.invalidate()
        updateLatestBlock = nil
    }

    @objc func fetch() {
        let request = EtherServiceRequest(batch: BatchFactory().create(BlockNumberRequest()))
        Session.send(request) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let number):
                self.latestBlock = number
            case .failure: break
            }
        }
    }

    func confirmations(fromBlock: Int) -> Int? {
        let block = latestBlock - fromBlock
        guard latestBlock != 0, block >= 0 else { return nil }
        return max(0, block)
    }

}
