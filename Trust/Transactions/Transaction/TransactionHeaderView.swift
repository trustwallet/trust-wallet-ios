// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class TransactionHeaderView: UIView {

    let amountLabel = UILabel(frame: .zero)

    override init(frame: CGRect = .zero) {

        super.init(frame: frame)

        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.textAlignment = .center

        addSubview(amountLabel)

        amountLabel.anchor(to: self, margin: 15)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
