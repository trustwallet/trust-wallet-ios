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

    init(
        wallet: WalletInfo
    ) {
        self.wallet = wallet
    }

    var title: String {
        return R.string.localizable.manage()
    }

    var name: String {
        if wallet.info.name.isEmpty {
            return WalletInfo.emptyName
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
                        .exportKeystore(wallet.currentAccount),
                        .exportPrivateKey(wallet.currentAccount),
                    ]
                ),
                FormSection(
                    footer: wallet.currentAccount.address.description,
                    rows: [
                        .copyAddress(wallet.address),
                    ]
                ),
            ]
        case .hd(let account):
            if wallet.multiWallet {
                return [
                    FormSection(
                        footer: R.string.localizable.multiCoinWallet(),
                        rows: [
                            .exportRecoveryPhrase(account),
                        ]
                    ),
                ]
            }
            return [
                FormSection(
                    rows: [
                        .exportRecoveryPhrase(account),
                        .exportKeystore(wallet.currentAccount),
                        .exportPrivateKey(wallet.currentAccount),
                    ]
                ),
                FormSection(
                    footer: wallet.currentAccount.address.description,
                    rows: [
                        .copyAddress(wallet.address),
                    ]
                ),
            ]
        case .address(_, let address):
            return [
                FormSection(
                    footer: wallet.currentAccount.address.description,
                    rows: [
                        .copyAddress(address),
                    ]
                ),
            ]
        }
    }
}
