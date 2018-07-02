// Copyright SIX DAY LLC. All rights reserved.

import TrustCore
import UIKit

protocol AccountViewCellDelegate: class {
    func accountViewCell(_ cell: AccountViewCell, didTapInfoViewForAccount _: WalletInfo)
}

class AccountViewCell: UITableViewCell {

    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var activeView: UIView!
    @IBOutlet weak var glassesImageView: UIImageView!
    @IBOutlet weak var walletTypeImageView: UIImageView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var identiconImageView: UIImageView!

    weak var delegate: AccountViewCellDelegate?

    var viewModel: AccountViewModel? {
        didSet {
            guard let model = viewModel else {
                return
            }
            balanceLabel.text = model.balanceText
            glassesImageView.isHidden = !model.isWatch
            activeView.isHidden = !model.isActive
            addressLabel.text = model.title
            infoButton.tintColor = Colors.lightBlue
            identiconImageView.image = model.identicon
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.viewModel = nil
    }

    @IBAction func infoAction(_ sender: Any) {
        guard let account = viewModel?.wallet else {
            return
        }
        delegate?.accountViewCell(self, didTapInfoViewForAccount: account)
    }
}
