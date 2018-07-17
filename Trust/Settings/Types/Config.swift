// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore

struct Config {

    struct Keys {
        static let chainID = "chainID"
        static let isCryptoPrimaryCurrency = "isCryptoPrimaryCurrency"
        static let isDebugEnabled = "isDebugEnabled"
        static let currencyID = "currencyID"
        static let dAppBrowser = "dAppBrowser"
        static let testNetworkWarningOff = "testNetworkWarningOff"
    }

    static let dbMigrationSchemaVersion: UInt64 = 60

    static let current: Config = Config()

    let defaults: UserDefaults

    init(
        defaults: UserDefaults = UserDefaults.standard
    ) {
        self.defaults = defaults
    }

    var currency: Currency {
        get {
            //If it is saved currency
            if let currency = defaults.string(forKey: Keys.currencyID) {
                return Currency(rawValue: currency)!
            }
            //If ther is not saved currency try to use user local currency if it is supported.
            let avaliableCurrency = Currency.allValues.first { currency in
                return currency.rawValue == Locale.current.currencySymbol
            }
            if let isAvaliableCurrency = avaliableCurrency {
                return isAvaliableCurrency
            }
            //If non of the previous is not working return USD.
            return Currency.USD
        }
        set { defaults.set(newValue.rawValue, forKey: Keys.currencyID) }
    }

    var chainID: Int {
        get {
            let id = defaults.integer(forKey: Keys.chainID)
            guard id > 0 else { return RPCServer.main.chainID }
            return id
        }
        set { defaults.set(newValue, forKey: Keys.chainID) }
    }

    var isCryptoPrimaryCurrency: Bool {
        get { return defaults.bool(forKey: Keys.isCryptoPrimaryCurrency) }
        set { defaults.set(newValue, forKey: Keys.isCryptoPrimaryCurrency) }
    }

    var server: RPCServer {
        return RPCServer(chainID: chainID)
    }

    var servers: [Coin] {
        return [
            Coin.ethereum,
            Coin.ethereumClassic,
            Coin.poa,
            Coin.callisto,
            Coin.gochain,
        ]
    }

    var testNetworkWarningOff: Bool {
        get { return defaults.bool(forKey: Keys.testNetworkWarningOff) }
        set { defaults.set(newValue, forKey: Keys.testNetworkWarningOff) }
    }

    var openseaURL: URL? {
        return URL(string: server.openseaPath)
    }

    func opensea(with contract: String, and id: String) -> URL? {
        return URL(string: (server.openseaPath + "/assets/\(contract)/\(id)"))
    }
}
