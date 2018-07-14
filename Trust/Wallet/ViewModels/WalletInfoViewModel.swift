// Copyright DApps Platform Inc. All rights reserved.

import Foundation

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

    var nameTitle: String {
        return R.string.localizable.name()
    }

    var sections: [FormSection] {
        switch wallet.wallet.type {
        case .privateKey(let account):
            return [
                FormSection(
                    rows: [
                        .exportKeystore(wallet.wallet.account!),
                        .exportPrivateKey(wallet.wallet.account!),
                    ]
                ),
                FormSection(
                    footer: wallet.address.description,
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
                        .exportPrivateKey(wallet.wallet.account!),
                    ]
                ),
                FormSection(
                    footer: wallet.address.description,
                    rows: [
                        .copyAddress(wallet.address),
                    ]
                ),
            ]
        case .address(let address):
            return [
                FormSection(
                    footer: wallet.address.description,
                    rows: [
                        .copyAddress(address),
                    ]
                ),
            ]
        }
    }
}
