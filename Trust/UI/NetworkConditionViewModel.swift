// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

struct NetworkConditionViewModel {

    let condition: NetworkCondition
    private let formmater = StringFormatter()

    init(
        condition: NetworkCondition
    ) {
        self.condition = condition
    }

    var localizedTitle: String {
        return Config().server.name
    }

    var color: UIColor {
        switch condition {
        case .good: return Colors.green
        case .bad: return Colors.red
        }
    }

    var block: String? {
        switch condition {
        case .good(let block): return formmater.formatter(for: block)
        case .bad: return "--"
        }
    }
}
