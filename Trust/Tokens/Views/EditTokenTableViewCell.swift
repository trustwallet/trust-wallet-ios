// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Kingfisher

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
            guard let viewModel = viewModel else { return }
            tokenLabel.text = viewModel.title
            tokenLabel.font = viewModel.titleFont
            tokenLabel.textColor = viewModel.titleTextColor
            tokenEnableSwitch.isOn = viewModel.isEnabled
            tokenImageView.kf.setImage(
                with: viewModel.imageUrl,
                placeholder: viewModel.placeholderImage,
                options: [.fromMemoryCacheOrRefresh]
            )
        }
    }

    @IBAction func didChangeSwitch(_ sender: UISwitch) {
        delegate?.didChangeState(state: sender.isOn, in: self)
    }
}
