// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import RandomColorSwift

final class NonFungibleCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subTitle: UILabel!
    @IBOutlet weak var imageViewBackground: UIView!
    @IBOutlet private weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.4
        self.layer.masksToBounds = false
        imageViewBackground.backgroundColor = randomColor(hue: .random, luminosity: .light).withAlphaComponent(0.3)
    }

    func configure(with viewModel: NonFungibleCollectionViewCellModel) {
        title.text = viewModel.name
        subTitle.text = viewModel.annotation
        imageView.kf.setImage(
            with: viewModel.imagePath,
            placeholder: R.image.launch_screen_logo()
        )
    }
}
