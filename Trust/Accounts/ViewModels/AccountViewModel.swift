// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct AccountViewModel {

    let account: Account
    let colorHash = PFColorHash()

    init(account: Account) {
        self.account = account
    }

    var title: String {
        return account.address.address
    }

    var image: UIImage? {
        let color = UIColor(hex: colorHash.hex(account.address.address))
        return UIImage.filled(with: color)
    }
}
