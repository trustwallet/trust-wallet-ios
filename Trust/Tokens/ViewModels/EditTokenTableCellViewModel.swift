// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct EditTokenTableCellViewModel {

    let token: TokenObject

    init(
        token: TokenObject
    ) {
        self.token = token
    }

    var title: String {
        return token.name.isEmpty ? token.symbol : token.name
    }

    var image: UIImage? {
        return R.image.ethereumToken()
    }

    var isEnabled: Bool {
        return token.isEnabled
    }
}
