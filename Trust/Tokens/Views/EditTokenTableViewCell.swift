// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import Kingfisher

protocol EditTokenTableViewCellDelegate: class {
    func didChangeState(state: Bool, in cell: EditTokenTableViewCell)
}

final class EditTokenTableViewCell: UITableViewCell {

    @IBOutlet weak var tokenImageView: TokenImageView!
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var tokenEnableSwitch: UISwitch!
    @IBOutlet weak var tokenContractLabel: UILabel!
    weak var delegate: EditTokenTableViewCellDelegate?

    var viewModel: EditTokenTableCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            tokenLabel.text = viewModel.title
            tokenLabel.font = viewModel.titleFont
            tokenLabel.textColor = viewModel.titleTextColor
            tokenEnableSwitch.isOn = viewModel.isEnabled
            tokenContractLabel.text = viewModel.contractText
            tokenContractLabel.isHidden = viewModel.isTokenContractLabelHidden
            tokenEnableSwitch.isHidden = viewModel.isSwitchHidden
            tokenImageView.kf.setImage(
                with: viewModel.imageUrl,
                placeholder: viewModel.placeholderImage
            )
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateSeparatorInset()
    }

    private func updateSeparatorInset() {
        separatorInset = UIEdgeInsets(
            top: 0,
            left: layoutInsets.left + EditTokenStyleLayout.sideMargin + EditTokenStyleLayout.preferedImageSize + EditTokenStyleLayout.sideMargin,
            bottom: 0, right: 0
        )
    }

    @IBAction func didChangeSwitch(_ sender: UISwitch) {
        delegate?.didChangeState(state: sender.isOn, in: self)
    }
}
