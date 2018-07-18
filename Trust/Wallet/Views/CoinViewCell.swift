// Copyright DApps Platform Inc. All rights reserved.

import UIKit

class CoinViewCell: UITableViewCell {

    @IBOutlet weak var coinImageView: TokenImageView!
    @IBOutlet weak var coinLabel: UILabel!

    override func layoutSubviews() {
        super.layoutSubviews()

        updateSeparatorInset()
    }

    func configure(for viewModel: CoinViewModel) {
        coinImageView.image = viewModel.image
        coinLabel.text = viewModel.walletName
    }

    private func updateSeparatorInset() {
        separatorInset = UIEdgeInsets(
            top: 0,
            left: layoutInsets.left + 76,
            bottom: 0, right: 0
        )
    }
}
