// Copyright DApps Platform Inc. All rights reserved.

import Foundation

public struct Constants {
    public static let keychainKeyPrefix = "trustwallet"
    public static let keychainTestsKeyPrefix = "trustwallet-tests"

    // social
    public static let website = "https://iposlab.com"
    public static let twitterUsername = "iposisanotheros"
    public static let defaultTelegramUsername = "iposio"
    public static let facebookUsername = ""

    public static var localizedTelegramUsernames = ["ru": "iposio", "vi": "iposio", "es": "iposio", "zh": "iposio", "ja": "iposio", "de": "iposio", "fr": "iposio"]

    // support
    public static let supportEmail = "support@iposlab.com"

    public static let dappsBrowserURL = "https://explorer.iposlab.com"
    public static let dappsOpenSea = "https://opensea.io"
    public static let dappsRinkebyOpenSea = "https://rinkeby.opensea.io"

    public static let images = "https://iposlab.com/images"

    //public static let trustAPI = URL(string: "http://public.trustwalletapp.com")!
    public static let trustAPI = URL(string: "http://iposwallet.herokuapp.com")!
    public static let priceAPI = URL(string: "http://price.iposlab.com")!
}

public struct UnitConfiguration {
    public static let gasPriceUnit: EthereumUnit = .gwei
    public static let gasFeeUnit: EthereumUnit = .ether
}

public struct URLSchemes {
    public static let trust = "app://"
    public static let browser = trust + "browser"
}
