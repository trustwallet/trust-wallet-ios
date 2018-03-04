// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Kingfisher

class NonFungibleTokenViewCell: UITableViewCell {

    static let identifier = "NonFungibleTokenViewCell"

    @IBOutlet weak var tokenImageView: UIImageView!

    @IBOutlet weak var annotationTextLabel: UILabel!

    @IBOutlet weak var nameTextLabel: UILabel!

    func configure(viewModel: NonFungibleTokenCellViewModel) {
        tokenImageView.kf.setImage(
            with: viewModel.imagePath,
            placeholder: UIImage(named: "launch_screen_logo")
        )
        nameTextLabel.text = viewModel.name
        annotationTextLabel.text = viewModel.annotation
    }
}
