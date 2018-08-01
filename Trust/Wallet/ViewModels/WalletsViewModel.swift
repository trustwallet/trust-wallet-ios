// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustCore

protocol WalletsViewModelProtocol: class {
    func update()
}

class WalletsViewModel {

    private let keystore: Keystore
    private let networks: [WalletInfo] = []
    private let importedWallet: [WalletInfo] = []

    var sections: [WalletAccountViewModel] = []
    private let operationQueue: OperationQueue = OperationQueue()
    weak var delegate: WalletsViewModelProtocol?

    init(
        keystore: Keystore
    ) {
        self.keystore = keystore
    }

    func refresh() {
        self.sections = self.keystore.wallets.compactMap {
            return WalletAccountViewModel(keystore: keystore, wallet: $0, account: $0.currentAccount, currentWallet: keystore.recentlyUsedWallet)
        }
    }

    func fetchBalances() {

        guard operationQueue.operationCount == 0 else { return }

        var valueProviders = [(WalletBalanceProvider, WalletObject)]()

        for wallet in self.keystore.wallets {
            guard let server = wallet.coin?.server, let address = EthereumAddress(string: wallet.currentAccount.address.description)   else { continue }
            valueProviders.append((WalletBalanceProvider(server: server, addressUpdate: address), wallet.info))
        }

        let operations: [WalletValueOperation] = valueProviders.compactMap {
            return  WalletValueOperation(balanceProvider: $0.0, keystore: keystore, wallet: $0.1)
        }

        operations.onFinish { [weak self] in
            DispatchQueue.main.async {
                 self?.delegate?.update()
            }
        }

        operationQueue.addOperations(operations, waitUntilFinished: false)
    }

    var title: String {
        return R.string.localizable.wallets()
    }

    var numberOfSection: Int {
        return 1
    }

    func numberOfRows(in section: Int) -> Int {
        return sections.count
    }

    func cellViewModel(for indexPath: IndexPath) -> WalletAccountViewModel {
        return sections[indexPath.row]
    }

    func canEditRowAt(for indexPath: IndexPath) -> Bool {
        return cellViewModel(for: indexPath).canDelete
    }
}
