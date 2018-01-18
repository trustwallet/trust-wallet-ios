// Copyright SIX DAY LLC. All rights reserved.

import Foundation

public struct Constants {
    public static let coinbaseWidgetCode = "88d6141a-ff60-536c-841c-8f830adaacfd"
    public static let shapeShiftPublicKey = "c4097b033e02163da6114fbbc1bf15155e759ddfd8352c88c55e7fef162e901a800e7eaecf836062a0c075b2b881054e0b9aa2324be7bc3694578493faf59af4"
    public static let changellyRefferalID = "968d4f0f0bf9"
    //
    public static let keychainKeyPrefix = "trustwallet"

    // social
    public static let website = "https://trustwalletapp.com"
    public static let twitterUsername = "trustwalletapp"
    public static let telegramUsername = "trustwallet"
    public static let facebookUsername = "trustwalletapp"

    // support
    public static let supportEmail = "support@trustwalletapp.com"
    public static let donationAddress = "0x9f8284ce2cf0c8ce10685f537b1fff418104a317"
}

public struct UnitConfiguration {
    public static let gasPriceUnit: EthereumUnit = .gwei
    public static let gasFeeUnit: EthereumUnit = .ether
}
