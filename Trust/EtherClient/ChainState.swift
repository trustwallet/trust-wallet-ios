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
        return Keys.latestBlock + "-\(config.chainID)"
    }

    var latestBlock: Int {
        get {
            return defaults.integer(forKey: latestBlockKey)
        }
        set { defaults.set(newValue, forKey: latestBlockKey) }
    }
    let defaults: UserDefaults

    var updateTransactionsTimer: Timer?

    init(
        config: Config
    ) {
        self.config = config
        self.defaults = config.defaults
        self.updateTransactionsTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(fetch), userInfo: nil, repeats: true)
    }

    func start() {
        fetch()
    }

    func stop() {
        updateTransactionsTimer?.invalidate()
        updateTransactionsTimer = nil
    }

    @objc func fetch() {
        let request = EtherServiceRequest(batch: BatchFactory().create(BlockNumberRequest()))
        Session.send(request) { result in
            switch result {
            case .success(let number):
                self.latestBlock = number
            case .failure: break
            }
        }
    }
}
