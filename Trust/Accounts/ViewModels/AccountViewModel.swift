// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore
import UIKit

struct AccountViewModel {

    let wallet: Wallet
    let current: Wallet?

    init(wallet: Wallet, current: Wallet?) {
        self.wallet = wallet
        self.current = current
    }

    var title: String {
        return wallet.address.description
    }

    var image: UIImage? {
        if isActive {
            return UIImage.filled(with: Colors.lightBlack)
        }
        return nil
    }

    var isActive: Bool {
        return wallet == current
    }
}
