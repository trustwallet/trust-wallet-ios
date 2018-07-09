// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

final class TokenInfoCoordinator: RootCoordinator {
    let token: TokenObject
    var rootViewController: UIViewController {
        return TokenInfoViewController(token: token)
    }
    var coordinators: [Coordinator] = []

    init(token: TokenObject) {
        self.token = token
    }
}
