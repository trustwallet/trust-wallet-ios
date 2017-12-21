// Copyright SIX DAY LLC. All rights reserved.

import UIKit

protocol EditTokenTableViewCellDelegate: class {
    func didChangeState(state: Bool, in cell: EditTokenTableViewCell)
}

class EditTokenTableViewCell: UITableViewCell {

    @IBOutlet weak var tokenImageView: UIImageView!
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var tokenEnableSwitch: UISwitch!
    weak var delegate: EditTokenTableViewCellDelegate?

    var viewModel: EditTokenTableCellViewModel? {
        didSet {
            tokenImageView.image = viewModel?.image
            tokenLabel.text = viewModel?.title
            tokenEnableSwitch.isOn = viewModel?.isEnabled ?? false
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func didChangeSwitch(_ sender: UISwitch) {
        delegate?.didChangeState(state: sender.isOn, in: self)
    }
}
