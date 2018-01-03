// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct HelpUsViewModel {

    var title: String {
        return NSLocalizedString("welldone.navigation.title", value: "Thank you!", comment: "")
    }

    private let sharingText: [String] = [
        NSLocalizedString(
            "welldone.viewmodel.sharing.text1",
            value: "Here is the app I use to store my ETH and ERC20 tokens",
            comment: ""
        ),
        NSLocalizedString(
            "welldone.viewmodel.sharing.text2",
            value: "Check out Trust - the wallet that lets me securely store my Ethereum and ERC20 tokens",
            comment: ""
        ),
    ]

    var activityItems: [Any] {
        return [
            sharingText[Int(arc4random_uniform(UInt32(sharingText.count)))],
            URL(string: Constants.website)!,
        ]
    }
}
