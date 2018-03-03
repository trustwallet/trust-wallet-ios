// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Kingfisher

class NonFungibleTokenViewCell: UITableViewCell {

    @IBOutlet weak var tokenImageView: UIImageView!
    @IBOutlet weak var annotationTextLabel: UILabel!
    @IBOutlet weak var nameTextLabel: UILabel!

    func configure(viewModel: NonFungibleTokenViewModel) {
        //tokenImageView.kf.setImage(
        //    with: viewModel.imageURL,
        //    placeholder: nil
        //)
        //nameTextLabel.text = viewModel.name
    }
}
