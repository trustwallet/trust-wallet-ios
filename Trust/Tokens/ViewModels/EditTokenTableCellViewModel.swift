// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

struct EditTokenTableCellViewModel {

    private let viewModel: TokenObjectViewModel
    private let coinTicker: CoinTicker?
    private let isLocal: Bool

    init(
        viewModel: TokenObjectViewModel,
        coinTicker: CoinTicker?,
        isLocal: Bool = true
    ) {
        self.viewModel = viewModel
        self.coinTicker = coinTicker
        self.isLocal = isLocal
    }

    var title: String {
        return viewModel.title
    }

    var titleFont: UIFont {
        return UIFont.systemFont(ofSize: 18, weight: .medium)
    }

    var titleTextColor: UIColor {
        return Colors.black
    }

    var placeholderImage: UIImage? {
        return viewModel.placeholder
    }

    var imageUrl: URL? {
        return viewModel.imageURL
    }

    var isEnabled: Bool {
        return !viewModel.token.isDisabled
    }

    var contractText: String? {
        switch viewModel.token.type {
        case .coin:
            return .none
        case .ERC20:
            return viewModel.token.contract + " (ERC20) "
        }
    }

    var isTokenContractLabelHidden: Bool {
        if contractText == nil {
            return true
        }
        return false
    }

    var isSwitchHidden: Bool {
        return !isLocal
    }
}
