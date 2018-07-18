// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustKeystore

struct FormSection {
    let footer: String?
    let header: String?
    let rows: [WalletInfoType]

    init(footer: String? = .none, header: String? = .none, rows: [WalletInfoType]) {
        self.footer = footer
        self.header = header
        self.rows = rows
    }
}

struct WalletInfoViewModel {

    let wallet: WalletInfo
    let currentAccount: Account

    init(
        wallet: WalletInfo,
        account: Account
    ) {
        self.wallet = wallet
        self.currentAccount = account
    }

    var title: String {
        return R.string.localizable.manage()
    }

    var name: String {
        guard !wallet.mainWallet else {
            return CoinViewModel(coin: wallet.coin ?? .ethereum).displayName
        }
        return wallet.info.name
    }

    var nameTitle: String {
        return R.string.localizable.name()
    }

    var sections: [FormSection] {
        switch wallet.type {
        case .privateKey:
            return [
                FormSection(
                    rows: [
                        .exportKeystore(currentAccount),
                        .exportPrivateKey(currentAccount),
                    ]
                ),
                FormSection(
                    footer: currentAccount.address.description,
                    rows: [
                        .copyAddress(wallet.address),
                    ]
                ),
            ]
        case .hd(let account):
            return [
                FormSection(
                    rows: [
                        .exportRecoveryPhrase(account),
                        //.exportKeystore(account),
                        .exportPrivateKey(currentAccount),
                    ]
                ),
                FormSection(
                    footer: currentAccount.address.description,
                    rows: [
                        .copyAddress(wallet.address),
                    ]
                ),
            ]
        case .address(_, let address):
            return [
                FormSection(
                    footer: currentAccount.address.description,
                    rows: [
                        .copyAddress(address),
                    ]
                ),
            ]
        }
    }

    var canEditName: Bool {
        return !wallet.mainWallet
    }
}
