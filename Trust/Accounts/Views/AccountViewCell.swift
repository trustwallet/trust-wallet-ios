// Copyright SIX DAY LLC. All rights reserved.

import TrustCore
import UIKit

protocol AccountViewCellDelegate: class {
    func accountViewCell(_ cell: AccountViewCell, didTapInfoViewForAccount _: Wallet)
}

class AccountViewCell: UITableViewCell {
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var activeView: UIView!
    @IBOutlet weak var glassesImageView: UIImageView!
    @IBOutlet weak var walletTypeImageView: UIImageView!
    @IBOutlet weak var addressLable: UILabel!
    @IBOutlet weak var balanceLable: UILabel!
    @IBOutlet weak var identiconImageView: UIImageView!
    weak var delegate: AccountViewCellDelegate?
    var viewModel: AccountViewModel? {
        didSet {
            guard let model = viewModel else {
                return
            }
            balanceLable.text = model.balanceText
            glassesImageView.isHidden = !model.isWatch
            activeView.isHidden = !model.isActive
            addressLable.text = model.title
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
