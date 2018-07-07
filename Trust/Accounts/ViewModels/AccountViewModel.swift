// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import JdenticonSwift
import TrustCore
import UIKit

struct AccountViewModel {
    let identiconSize = 60 as CGFloat
    let wallet: WalletInfo
    let current: WalletInfo?
    let server: RPCServer

    init(
        server: RPCServer,
        wallet: WalletInfo,
        current: WalletInfo?
    ) {
        self.server = server
        self.wallet = wallet
        self.current = current
    }

    var isWatch: Bool {
        return wallet.wallet.type == .address(wallet.address)
    }

    var title: String {
        guard wallet.info.name.isEmpty else {
            return wallet.info.name
        }
        return WalletInfo.emptyName
    }

    var subTitle: String {
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
