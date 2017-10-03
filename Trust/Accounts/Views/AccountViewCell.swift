// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class AccountViewCell: UITableViewCell {

    static let identifier = "AccountViewCell"

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
