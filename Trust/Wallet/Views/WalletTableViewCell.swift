// Copyright DApps Platform Inc. All rights reserved.

import UIKit

protocol WalletTableViewCellDelegate: class {
    func didPress(viewModel: WalletAccountViewModel, in cell: WalletTableViewCell)
}

class WalletTableViewCell: UITableViewCell {

    @IBOutlet weak var tokenImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subNameLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!

    weak var delegate: WalletTableViewCellDelegate?

    var viewModel: WalletAccountViewModel? {
        didSet {
            guard let model = viewModel else { return }

            nameLabel.text = model.title //.wallet.info.name
            subNameLabel.text = model.subbtitle //.wallet.address.description
            tokenImageView.image = R.image.backup_warning()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.viewModel = nil
    }

    @IBAction func infoButtonPressed(_ sender: Any) {
        guard let model = viewModel else { return }
        delegate?.didPress(viewModel: model, in: self)
    }
}
