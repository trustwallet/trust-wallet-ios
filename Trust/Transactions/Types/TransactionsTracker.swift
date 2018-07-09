// Copyright DApps Platform Inc. All rights reserved.

import Foundation

enum TransactionFetchingState: Int {
    case initial = 0
    case failed
    case done

    init(int: Int) {
        self = TransactionFetchingState(rawValue: int) ?? .initial
    }
}

final class TransactionsTracker {
    private var fetchingStateKey: String {
        return "transactions.fetchingState-\(sessionID)"
    }

    let sessionID: String
    let defaults: UserDefaults

    var fetchingState: TransactionFetchingState {
        get { return TransactionFetchingState(int: defaults.integer(forKey: fetchingStateKey)) }
        set { return defaults.set(newValue.rawValue, forKey: fetchingStateKey) }
    }

    init(
        sessionID: String,
        defaults: UserDefaults = .standard
    ) {
        self.sessionID = sessionID
        self.defaults = defaults
    }
}
