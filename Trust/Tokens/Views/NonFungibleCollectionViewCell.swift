// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class NonFungibleCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subTitle: UILabel!
    @IBOutlet private weak var imageViewBackground: UIView!
    @IBOutlet private weak var imageView: UIImageView!

    func config(with viewModel: NonFungibleCollectionViewCellModel) {
        imageViewBackground.backgroundColor = UIColor.random()
        title.text = viewModel.name
        subTitle.text = viewModel.annotation
        imageView.kf.setImage(
            with: viewModel.imagePath,
            placeholder: R.image.launch_screen_logo()
        )
    }
}
