// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct TokensViewModel {

    var tokens: [TokenObject] = []

    init(
        tokens: [TokenObject]
    ) {
        self.tokens = tokens
    }

    var title: String {
        return NSLocalizedString("tokens.navigation.title", value: "Tokens", comment: "")
    }

    var backgroundColor: UIColor {
        return .white
    }

    var hasContent: Bool {
        return !tokens.isEmpty
    }

    var numberOfSections: Int {
        return 1
    }

    func numberOfItems(for section: Int) -> Int {
        return tokens.count
    }

    func item(for row: Int, section: Int) -> TokenObject {
        return tokens[row]
    }

    func canDelete(for row: Int, section: Int) -> Bool {
        let token = item(for: row, section: section)
        return token.isCustom || token.valueBigInt.isZero
    }
}
