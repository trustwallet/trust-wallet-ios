// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JdenticonSwift
import TrustKeystore
import UIKit

struct AccountViewModel {
    let identiconSize = 60 as CGFloat
    let wallet: Wallet
    let current: Wallet?
    let walletBalance: Balance?
    let server: RPCServer

    init(
        server: RPCServer,
        wallet: Wallet,
        current: Wallet?,
        walletBalance: Balance?
    ) {
        self.server = server
        self.wallet = wallet
        self.current = current
        self.walletBalance = walletBalance
    }

    var isWatch: Bool {
        return wallet.type == .address(wallet.address)
    }

    var balanceText: String {
        guard let amount = walletBalance?.amountFull else { return "--" }
        return "\(amount) \(server.symbol)"
    }

    var title: String {
        return wallet.address.description
    }

    var isActive: Bool {
        return wallet == current
    }

    var identicon: UIImage? {
        guard let cgImage = IconGenerator(size: identiconSize, hash: wallet.address.data).render() else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
