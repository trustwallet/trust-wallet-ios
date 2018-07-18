// Copyright DApps Platform Inc. All rights reserved.

import UIKit

class CoinViewCell: UITableViewCell {

    @IBOutlet weak var coinImageView: TokenImageView!
    @IBOutlet weak var coinLabel: UILabel!

    func configure(for viewModel: CoinViewModel) {
        coinImageView.image = viewModel.image
        coinLabel.text = viewModel.displayName
    }
}
