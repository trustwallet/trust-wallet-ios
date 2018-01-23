// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class MarketplaceItemTableViewCell: UITableViewCell {

    var viewModel: MarketplaceItemViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            nameLabel.text = viewModel.name
            descriptionLabel.text = viewModel.description
            itemImageView.kf.setImage(
                with: viewModel.imageURL,
                placeholder: viewModel.placeholderImage
            )
        }
    }

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
}
