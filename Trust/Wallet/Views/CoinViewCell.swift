// Copyright DApps Platform Inc. All rights reserved.

import UIKit

class CoinViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(for viewModel: CoinViewModel) {
        textLabel?.text = viewModel.displayName
    }
}
