// Copyright SIX DAY LLC. All rights reserved.

import Foundation

class AppTracker {

    struct Keys {
        static let launchCountTotal = "launchCountTotal"
        static let launchCountForCurrentBuild = "launchCountForCurrentBuild-" + String(Bundle.main.buildNumberInt)
    }

    let defaults: UserDefaults

    var launchCountTotal: Int {
        get { return defaults.integer(forKey: Keys.launchCountTotal) }
        set { return defaults.set(newValue, forKey: Keys.launchCountTotal) }
    }

    var launchCountForCurrentBuild: Int {
        get { return defaults.integer(forKey: Keys.launchCountForCurrentBuild) }
        set { return defaults.set(newValue, forKey: Keys.launchCountForCurrentBuild) }
    }

    init(
        defaults: UserDefaults = .standard
    ) {
        self.defaults = defaults
    }

    func start() {
        launchCountTotal += launchCountTotal
        launchCountForCurrentBuild += 1
    }

    var description: String {
        return """
        launchCountTotal: \(launchCountTotal)
        launchCountForCurrentBuild: \(launchCountForCurrentBuild)
        """
    }
}
