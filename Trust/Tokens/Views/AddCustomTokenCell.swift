// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class AddCustomTokenCell: UITableViewCell {

    @IBOutlet var label: UILabel!

    func config(with model: AddCustomTokenCellViewModel) {
        label.text = model.title
    }
}
