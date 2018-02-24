// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct NewTokenViewModel {
    let token: ERC20Token?

    init(token: ERC20Token?) {
        self.token = token
    }

    var title: String {
        switch token {
        case .some:
            return NSLocalizedString("tokens.token.edit.navigation.title", value: "Edit Custom Token", comment: "")
        case .none:
            return NSLocalizedString("tokens.newtoken.navigation.title", value: "Add Custom Token", comment: "")
        }
    }

    var contract: String {
        return token?.contract.description ?? ""
    }

    var name: String {
        return token?.name ?? ""
    }

    var symbol: String {
        return token?.symbol ?? ""
    }

    var decimals: String {
        guard let decimals = token?.decimals else { return "" }
        return "\(decimals)"
    }
}
