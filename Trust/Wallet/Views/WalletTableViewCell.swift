// Copyright DApps Platform Inc. All rights reserved.

import UIKit

class WalletTableViewCell: UITableViewCell {

    @IBOutlet weak var tokenImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(for viewModel: WalletInfoViewModel) {
        nameLabel.text = viewModel.wallet.info.name
        subNameLabel.text = viewModel.wallet.address.description
        tokenImageView.image = R.image.backup_warning()
    }
}
