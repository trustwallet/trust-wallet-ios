// Copyright DApps Platform Inc. All rights reserved.

import TrustCore
import UIKit

protocol WalletViewCellDelegate: class {
    func didPress(viewModel: WalletAccountViewModel, in cell: WalletViewCell)
}

final class WalletViewCell: UITableViewCell {

    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var glassesImageView: UIImageView!
    @IBOutlet weak var walletTypeImageView: UIImageView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var identiconImageView: TokenImageView!

    weak var delegate: WalletViewCellDelegate?

    var viewModel: WalletAccountViewModel? {
        didSet {
            guard let model = viewModel else {
                return
            }
            addressLabel.text = model.title
            balanceLabel.text = model.subbtitle
            glassesImageView.isHidden = !model.isWatch
            infoButton.tintColor = Colors.lightBlue
            identiconImageView.image = model.image
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateSeparatorInset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.viewModel = nil
    }

    @IBAction func infoAction(_ sender: Any) {
        guard let viewModel = viewModel else { return }
        delegate?.didPress(viewModel: viewModel, in: self)
    }

    private func updateSeparatorInset() {
        separatorInset = UIEdgeInsets(
            top: 0,
            left: layoutInsets.left + 76,
            bottom: 0, right: 0
        )
    }
}
