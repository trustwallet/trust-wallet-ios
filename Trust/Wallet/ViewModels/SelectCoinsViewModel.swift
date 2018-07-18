// Copyright DApps Platform Inc. All rights reserved.

import Foundation

struct SelectCoinsViewModel {

    let elements: [CoinViewModel]

    init(elements: [CoinViewModel]) {
        self.elements = elements
    }

    var title: String {
        return R.string.localizable.importWalletImportButtonTitle()
    }

    var numberOfSection: Int {
        return 1
    }

    func numberOfRows(in section: Int) -> Int {
        return elements.count
    }
    func cellViewModel(for indexPath: IndexPath) -> CoinViewModel {
        return elements[indexPath.row]
    }
}
