// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import UIKit

struct TransactionViewModel {
    
    let transaction: Transaction
    
    init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    var title: String {
        return "Transaction"
    }
    
    var backgroundColor: UIColor {
        return .white
    }
}
