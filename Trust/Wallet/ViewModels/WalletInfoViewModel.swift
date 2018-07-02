// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct WalletInfoViewModel {

    let wallet: WalletInfo

    init(
        wallet: WalletInfo
    ) {
        self.wallet = wallet
    }

    var title: String {
        return R.string.localizable.manage()
    }

    var nameTitle: String {
        return R.string.localizable.name()
    }

    var types: [WalletInfoType] {
        switch wallet.wallet.type {
        case .privateKey(let account):
            return [
                .exportKeystore(account),
                .exportPrivateKey(account),
                .copyAddress(account.address),
            ]
        case .hd(let account):
            return [
                .exportRecoveryPhrase(account),
                .exportPrivateKey(account),
                .exportKeystore(account),
                .copyAddress(account.address),
            ]
        case .address(let address):
            return [
                .copyAddress(address),
            ]
        }
    }
}
